require 'capistrano/cli'
require 'pp'

module Sprinkle
  module Actors
    # = Capistrano Delivery Method
    #
    # Capistrano is one of the delivery method options available out of the
    # box with Sprinkle. If you have the capistrano gem install, you may use
    # this delivery. The only configuration option available, and which is 
    # mandatory to include is +recipes+. An example:
    #
    #   deployment do
    #     delivery :capistrano do
    #       recipes 'deploy'
    #     end
    #   end
    #
    # Recipes is given a list of files which capistrano will include and load.
    # These recipes are mainly to set variables such as :user, :password, and to 
    # set the app domain which will be sprinkled. 
    class Dummy < Actor #:nodoc:
      attr_accessor :config, :loaded_recipes #:nodoc:

      def initialize(&block) #:nodoc:
        # @config.set(:_sprinkle_actor, self)
        @roles={}
        self.instance_eval &block
      end

      # Defines a recipe file which will be included by capistrano. Use these
      # recipe files to set capistrano specific configurations. Default recipe
      # included is "deploy." But if any other recipe is specified, it will
      # include that instead. Multiple recipes may be specified through multiple
      # recipes calls, an example:
      #
      #   deployment do
      #     delivery :capistrano do
      #       recipes 'deploy'
      #       recipes 'magic_beans'
      #     end
      #   end
      # def recipes(script)
      # end
      
      def role(role, server, opts={})
        @roles[role]||=[]
        @roles[role] << [ server, opts ]
      end
      
      # Determines if there are any servers for the given roles
      def servers_for_role?(roles)
        roles=Array(roles)
        roles.any? { |r| @roles.keys.include? (r) }
      end
      
      def install(installer, roles, opts={})
        if per_host=opts.delete(:per_host)
          servers_per_role(roles).each do |server|
            installer.reconfigure_for(server)
            installer.announce
            process(installer.package.name, installer.install_sequence, server, opts)
          end
        else
          process(installer.package, installer.install_sequence, roles, opts)
        end
      end
      
      def verify(verifier, roles, opts = {})
        process(verifier.package.name, verifier.commands, roles, opts = {})
      end
      
      def servers_per_role(role)
        @roles[role]
      end

      def process(name, commands, roles, opts = {}) #:nodoc:
        # puts "PROCESS: #{name} on #{roles}"
        pp commands
        # return false if suppress_and_return_failures
        true
      end

      def transfer(name, source, destination, roles, recursive = true, suppress_and_return_failures = false)
        
      end
			
      private

        # REVISIT: can we set the description somehow?
        def define_task(name, roles, &block)
          @config.task task_sym(name), :roles => roles, &block
        end

        def run(task)
          @config.send task_sym(task)
        end

        def task_sym(name)
          "install_#{name.to_task_name}".to_sym
        end
    end
  end
end


=begin

# channel: the SSH channel object used for this response
# stream: either :err or :out, for stderr or stdout responses
# output: the text that the server is sending, might be in chunks
run "apt-get update" do |channel, stream, output|
   if output =~ /Are you sure?/
     answer = Capistrano::CLI.ui.ask("Are you sure: ")
     channel.send_data(answer + "\n")
   else
     # allow the default callback to be processed
     Capistrano::Configuration.default_io_proc.call[channel, stream, output]
   end
 end



 You can tell subversion to use a different username+password by
 setting a couple variables:
    set :svn_username, "my svn username"
    set :svn_password, "my svn password"
 If you don't want to set the password explicitly in your recipe like
 that, you can make capistrano prompt you for it like this:
    set(:svn_password) { Capistrano::CLI.password_prompt("Subversion
 password: ") }
 - Jamis
=end
