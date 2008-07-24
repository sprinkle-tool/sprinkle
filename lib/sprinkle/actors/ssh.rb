require 'net/ssh/gateway'

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
      
      def process(name, commands, roles, suppress_and_return_failures = false)
        return process_with_gateway(name, commands, roles) if gateway_defined?
        process_direct(name, commands, roles)
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
        
        def execute_on_role(commands, role, gateway = nil)
          hosts = @options[:roles][role]
          Array(hosts).each { |host| execute_on_host(commands, host, gateway) }
        end
        
        def execute_on_host(commands, host, gateway = nil)
          if gateway # SSH connection via gateway
            gateway.ssh(host, @options[:user]) do |ssh|
              execute_on_connection(commands, ssh)
            end
          else # direct SSH connection
            Net::SSH.start(host, @options[:user]) do |ssh|
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
