module Sprinkle
  module Actors
    # = Vlad Delivery Method
    #
    # Vlad is one of the delivery method options available out of the
    # box with Sprinkle. If you have the vlad the deployer gem install, you 
    # may use this delivery. The only configuration option available, and 
    # which is mandatory to include is +script+. An example:
    #
    #   deployment do
    #     delivery :vlad do
    #       script 'deploy'
    #     end
    #   end
    #
    # script is given a list of files which vlad will include and load.
    # These recipes are mainly to set variables such as :user, :password, and to 
    # set the app domain which will be sprinkled.
    class Vlad
      require 'vlad'
      attr_accessor :loaded_recipes #:nodoc:

      def initialize(&block) #:nodoc:
        self.instance_eval &block if block
      end

      # Defines a script file which will be included by vlad. Use these
      # script files to set vlad specific configurations. Multiple scripts
      # may be specified through multiple script calls, an example:
      #
      #   deployment do
      #     delivery :vlad do
      #       script 'deploy'
      #       script 'magic_beans'
      #     end
      #   end
      def script(name)
        @loaded_recipes ||= []
        require name
        @loaded_recipes << name
      end

      def process(name, commands, roles, suppress_and_return_failures = false) #:nodoc:
        commands = Array(commands)
        if use_sudo
          commands = commands.map{|x| "sudo #{x}"}
        end
        commands = commands.join(' && ')
        puts "executing #{commands}"
        t = remote_task(task_sym(name), :roles => roles) { run commands }
        
        begin
          t.invoke
          return true
        rescue ::Rake::CommandFailedError => e
          return false if suppress_and_return_failures
          
          # Reraise error if we're not suppressing it
          raise
        end
      end

			# Sorry, all transfers are recursive
      def transfer(name, source, destination, roles, recursive = true, suppress_and_return_failures = false) #:nodoc:
        begin
					rsync source, destination
          return true
        rescue ::Rake::CommandFailedError => e
          return false if suppress_and_return_failures
          
          # Reraise error if we're not suppressing it
          raise
        end
      end

      private

        def task_sym(name)
          "install_#{name.to_task_name}".to_sym
        end
    end
  end
end
