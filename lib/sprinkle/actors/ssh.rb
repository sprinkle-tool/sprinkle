require 'net/ssh/gateway'
require 'net/scp'

module Sprinkle
  module Actors
    class Ssh
      attr_accessor :options

      def initialize(options = {}, &block) #:nodoc:
        @options = options.update(:user => 'root')
        self.instance_eval &block if block
      end

      def roles(roles)
        @options[:roles] = roles
      end
      
      def gateway(gateway)
        @options[:gateway] = gateway
      end
      
      def user(user)
        @options[:user] = user
      end

      def password(password)
        @options[:password] = password
      end

      def process(name, commands, roles, suppress_and_return_failures = false)
        return process_with_gateway(name, commands, roles) if gateway_defined?
        r = process_direct(name, commands, roles)
        logger.debug green "process returning #{r}"
        return r
      end

      def transfer(name, source, destination, roles, recursive = true, suppress_and_return_failures = false)
        return transfer_with_gateway(name, source, destination, roles, recursive) if gateway_defined?
        transfer_direct(name, source, destination, roles, recursive)
      end
			
      protected
      
        def process_with_gateway(name, commands, roles)
          res = []
          on_gateway do |gateway|
            Array(roles).each { |role| res << execute_on_role(commands, role, gateway) }
          end
          !(res.include? false)
        end
        
        def process_direct(name, commands, roles)
          res = []
          Array(roles).each { |role| res << execute_on_role(commands, role) }
          !(res.include? false)
        end
        
        def transfer_with_gateway(name, source, destination, roles, recursive)
          on_gateway do |gateway|
            Array(roles).each { |role| transfer_to_role(source, destination, role, recursive, gateway) }
          end
        end
        
        def transfer_direct(name, source, destination, roles, recursive)
          Array(roles).each { |role| transfer_to_role(source, destination, role, recursive) }
        end

        def execute_on_role(commands, role, gateway = nil)
          hosts = @options[:roles][role]
          res = []
          Array(hosts).each { |host| res << execute_on_host(commands, host, gateway) }
          !(res.include? false)
        end

        def transfer_to_role(source, destination, role, gateway = nil)
          hosts = @options[:roles][role]
          Array(hosts).each { |host| transfer_to_host(source, destination, host, gateway) }
        end
        
        def execute_on_host(commands, host, gateway = nil)
          res = nil
          logger.debug(blue "executing #{commands.inspect} on #{host}.")
          if gateway # SSH connection via gateway
            gateway.ssh(host, @options[:user]) do |ssh|
              res = execute_on_connection(commands, ssh)
              ssh.loop
            end
          else # direct SSH connection
            Net::SSH.start(host, @options[:user], :password => @options[:password]) do |ssh|
              res = execute_on_connection(commands, ssh)
              ssh.loop
            end
          end
          res.detect{|x| x!=0}.nil?
        end

        def execute_on_connection(commands, session)
          res = []
          Array(commands).each do |cmd|
            session.open_channel do |channel|
              channel.on_data do |ch, data|
                logger.debug yellow("stdout said-->\n#{data}\n")
              end
              channel.on_extended_data do |ch, type, data|
                next unless type == 1  # only handle stderr
                logger.debug red("stderr said -->\n#{data}\n")
              end

              channel.on_request("exit-status") do |ch, data|
                exit_code = data.read_long
                if exit_code == 0
                  logger.debug(green 'success')
                else
                  logger.debug(red('failed (%d).'%exit_code))
                end
                res << exit_code
              end

              channel.on_request("exit-signal") do |ch, data|
                logger.debug red("#{cmd} was signaled!: #{data.read_long}")
              end

              channel.exec cmd  do  |ch, status|
                logger.error("couldn't run remote command #{cmd}") unless status
              end
            end
          end
          res
        end

        def transfer_to_host(source, destination, host, recursive, gateway = nil)
          if gateway # SSH connection via gateway
            gateway.ssh(host, @options[:user]) do |ssh|
              transfer_on_connection(source, destination, recursive, ssh)
            end
          else # direct SSH connection
            Net::SSH.start(host, @options[:user]) do |ssh|
              transfer_on_connection(source, destination, recursive, ssh)
            end
          end
        end

        def transfer_on_connection(source, destination, recursive, connection)
          scp = Net::SCP.new(connection)
          scp.upload! source, destination, :recursive => recursive
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

        def gateway_defined?
          !! @options[:gateway]
        end

        def on_gateway(&block)
          gateway = Net::SSH::Gateway.new(@options[:gateway], @options[:user])
          block.call gateway
        ensure
          gateway.shutdown!
        end
    end
  end
end
