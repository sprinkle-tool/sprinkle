require 'capistrano/cli'
require 'pp'

module Sprinkle
  module Actors
    class Dummy < Actor #:nodoc:
      
      attr_accessor :per_host

      def initialize(&block) #:nodoc:
        # @config.set(:_sprinkle_actor, self)
        @roles={}
        self.instance_eval(&block)
      end

      def role(role, server, opts={})
        @roles[role]||=[]
        @roles[role] << [ server, opts ]
      end
      
      # Determines if there are any servers for the given roles
      def servers_for_role?(roles)
        roles=Array(roles)
        roles.any? { |r| @roles.keys.include?(r) }
      end
      
      def install(installer, roles, opts={})
        @installer = installer
        if self.per_host=opts.delete(:per_host)
          servers_per_role(roles).each do |server|
            installer.reconfigure_for(server)
            installer.announce
            process(installer.package.name, installer.install_sequence, server, opts)
          end
        else
          process(installer.package, installer.install_sequence, roles, opts)
        end
      end
      
      def sudo?
        false
      end
      
      def verify(verifier, roles, opts = {})
        process(verifier.package.name, verifier.commands, roles, opts = {})
      end
      
      def servers_per_role(role)
        @roles[role]
      end
      
      def print_command(cmd)
        if cmd==:TRANSFER
            puts "#{cmd.inspect}: src: #{@installer.sourcepath} dst: #{@installer.destination}"
        else
          puts cmd.inspect
        end
      end

      def process(name, commands, roles, opts = {}) #:nodoc:
        # puts "PROCESS: #{name} on #{roles}"
        commands.each do |cmd|
          print_command(cmd)
        end
        # return false if suppress_and_return_failures
        true
      end
    end
  end
end
