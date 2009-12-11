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
        process_direct(name, commands, roles)
      end

      def transfer(name, source, destination, roles, recursive = true, suppress_and_return_failures = false)
        return transfer_with_gateway(name, source, destination, roles, recursive) if gateway_defined?
        transfer_direct(name, source, destination, roles, recursive)
      end
			
      protected
      
        def process_with_gateway(name, commands, roles)
          on_gateway do |gateway|
            Array(roles).each { |role| execute_on_role(commands, role, gateway) }
          end
        end
        
        def process_direct(name, commands, roles)
          Array(roles).each { |role| execute_on_role(commands, role) }
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
          Array(hosts).each { |host| execute_on_host(commands, host, gateway) }
        end

        def transfer_to_role(source, destination, role, gateway = nil)
          hosts = @options[:roles][role]
          Array(hosts).each { |host| transfer_to_host(source, destination, host, gateway) }
        end
        
        def execute_on_host(commands, host, gateway = nil)
          if gateway # SSH connection via gateway
            gateway.ssh(host, @options[:user]) do |ssh|
              execute_on_connection(commands, ssh)
            end
          else # direct SSH connection
            Net::SSH.start(host, @options[:user], :password => @options[:password]) do |ssh|
              execute_on_connection(commands, ssh)
            end
          end
        end
        
        def execute_on_connection(commands, connection)
          Array(commands).each do |command|
            connection.exec! command do |ch, stream, data|
              logger.send((stream == :stderr ? 'error' : 'debug'), data)
            end
          end
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
