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
    class Ssh
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
        process(verifier.package.name, verifier.commands, roles, 
          :suppress_and_return_failures => true)
      end
      
      def install(installer, roles, opts = {}) #:nodoc:
        process(installer.package.name, installer.install_sequence, roles)
      rescue SSHCommandFailure => e
        raise Sprinkle::Actors::RemoteCommandFailure.new(installer,e.details)
      end
      
      def transfer(name, source, destination, roles, opts={}) #:nodoc:
        opts.reverse_merge!(:recursive => true)
        Array(roles).each do |role| 
          transfer_to_role(source, destination, role, opts)
        end
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
          commands.map { |command| command.match(/^sudo/) ? command : "sudo #{command}" }
        end
        
        def execute_on_host(commands,host) #:nodoc:
          prepared_commands.each do |cmd|
            res = ssh(host, cmd)
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
        
        def ssh(host, cmd) #:nodoc:
          with_session(host) { |session| return channel_runner(session, cmd) }
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
          with_session(host) do |session|
            scp = Net::SCP.new(session)
            scp.upload! source, destination, :recursive => opts[:recursive]
          end
        end
        
        def with_session(host, &block) #:nodoc:
          if @gateway
            gateway.ssh(host, @options[:user]) { |ssh| yield(ssh) }
          else
            Net::SSH.start(host, @options[:user],:password => @options[:password]) { |ssh| yield(ssh) }
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
