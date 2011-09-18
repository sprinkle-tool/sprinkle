require 'net/ssh/gateway'
require 'net/scp'

module Sprinkle
  module Actors
    # The SSH actor requires no additional deployment tools other than the 
    # Ruby SSH libraries.
    #
    #   deployment do
    #     delivery :ssh do
    #       user "rails"
    #       password "leetz"
    #
    #       role :app, "app.myserver.com"
    #     end
    #   end
    #
    #
    # == Working thru a gateway
    #
    # If you're behind a firewall and need to use a SSH gateway that's fine.
    # 
    #   deployment do
    #     delivery :ssh do
    #       gateway "work.sshgateway.com"
    #     end
    #   end
    class SSH
      attr_accessor :options #:nodoc:
      
      class SSHCommandFailure < StandardError #:nodoc:
        attr_accessor :details
      end 
      
      def initialize(options = {}, &block) #:nodoc:
        @options = options.update(:user => 'root')
        @roles = {}
        self.instance_eval &block if block
        raise "You must define at least a single role." if @roles.empty?
      end

      # Define a whole host of roles at once
      #
      # This is depreciated - you should be using role instead.
      def roles(roles)
        @roles = roles
      end

      # Define a role and add servers to it
      #   
      #   role :app, "app.server.com"
      #   role :db, "db.server.com"
      def role(role, server)
        @roles[role] ||= []
        @roles[role] << server
      end
      
      # Set an optional SSH gateway server - if set all outbound SSH traffic
      # will go thru this gateway
      def gateway(gateway)
        @options[:gateway] = gateway
      end
      
      # Set the SSH user
      def user(user)
        @options[:user] = user
      end

      # Set the SSH password
      def password(password)
        @options[:password] = password
      end

      # Set this to true to prepend 'sudo' to every command.
      def use_sudo(value)
        @options[:use_sudo] = value
      end

      def setup_gateway #:nodoc:
        @gateway ||= Net::SSH::Gateway.new(@options[:gateway], @options[:user]) if @options[:gateway]
      end
      
      def teardown #:nodoc:
        @gateway.shutdown! if @gateway
      end
      
      def verify(verifier, roles, opts = {}) #:nodoc:
        @verifier = verifier
        # issue all the verification steps in a single SSH command
        commands=[verifier.commands.join(" && ")]
        process(verifier.package.name, commands, roles, 
          :suppress_and_return_failures => true)
      ensure
        @verifier = nil
      end
      
      def install(installer, roles, opts = {}) #:nodoc:
        @installer = installer
        process(installer.package.name, installer.install_sequence, roles)
      rescue SSHCommandFailure => e
        raise Sprinkle::Actors::RemoteCommandFailure.new(installer, e.details, e)
      ensure
        @installer = nil
      end

      protected
      
        def process(name, commands, roles, opts = {}) #:nodoc:
          opts.reverse_merge!(:suppress_and_return_failures => false)
          setup_gateway
          @suppress = opts[:suppress_and_return_failures]
          r=execute_on_role(commands, roles)
          logger.debug green "process returning #{r}"
          return r
        end      
      
        def execute_on_role(commands, role) #:nodoc:
          hosts = @roles[role]
          Array(hosts).each do |host| 
            success = execute_on_host(commands, host)
            return false unless success
          end
        end
        
        def prepared_commands
          return commands unless @options[:use_sudo]
          commands.map do |command| 
            next command if command.is_a?(Symbol)
            command.match(/^sudo/) ? command : "sudo #{command}"
          end
        end
        
        def execute_on_host(commands,host) #:nodoc:
          session = ssh_session(host)
          prepared_commands.each do |cmd|
            if cmd == :TRANSFER
              transfer_to_host(@installer.sourcepath, @installer.destination, session, 
                :recursive => @installer.options[:recursive])
              next
            end
            res = ssh(session, cmd)
            if res[:code] != 0 
              if @suppress
                return false
              else
                fail=SSHCommandFailure.new
                fail.details=res
                raise fail, "#{cmd} failed with error code #{res[:code]}"
              end
            end
          end
          true
        end
        
        def ssh(host, cmd, opts={}) #:nodoc:
          logger.debug "ssh: #{cmd}"
          session = host.is_a?(Net::SSH::Connection::Session) ? host : ssh_session(host)
          channel_runner(session, cmd)
        end
        
        def channel_runner(session, command) #:nodoc:
          res = {:error => "", :stdout => "", :command => command}
          session.open_channel do |channel|
            channel.on_data do |ch, data|
              res[:stdout] << data
              logger.debug yellow("stdout said-->\n#{data}\n")
            end
            channel.on_extended_data do |ch, type, data|
              next unless type == 1  # only handle stderr
              res[:error] << data
              logger.debug red("stderr said -->\n#{data}\n")
            end

            channel.on_request("exit-status") do |ch, data|
              res[:code] = data.read_long
              if res[:code] == 0
                logger.debug(green 'success')
              else
                logger.debug(red('failed (%d).'%res[:code]))
              end
            end

            channel.on_request("exit-signal") do |ch, data|
              logger.debug red("#{cmd} was signaled!: #{data.read_long}")
            end

            channel.exec command  do  |ch, status|
              logger.error("couldn't run remote command #{cmd}") unless status
            end
          end
          session.loop
          res
        end
        
        def transfer_to_role(source, destination, role, opts={}) #:nodoc:
          hosts = @roles[role]
          Array(hosts).each { |host| transfer_to_host(source, destination, host, opts) }
        end
        
        def transfer_to_host(source, destination, host, opts={}) #:nodoc:
          logger.debug "upload: #{destination}"
          session = host.is_a?(Net::SSH::Connection::Session) ? host : ssh_session(host)
          scp = Net::SCP.new(session)
          scp.upload! source, destination, :recursive => opts[:recursive], :chunk_size => 32.kilobytes
        rescue RuntimeError => e
          if e.message =~ /Permission denied/
            raise TransferFailure.no_permission(@installer,e)
          else
            raise e
          end          
        end
        
        def ssh_session(host)
          if @gateway
            gateway.ssh(host, @options[:user])
          else
            Net::SSH.start(host, @options[:user],:password => @options[:password])
          end
        end        
        
        private
        def color(code, s)
          "\033[%sm%s\033[0m"%[code,s]
        end
        def red(s)
          color(31, s)
        end
        def yellow(s)
          color(33, s)
        end
        def green(s)
          color(32, s)
        end
        def blue(s)
          color(34, s)
        end
    end
  end
end
