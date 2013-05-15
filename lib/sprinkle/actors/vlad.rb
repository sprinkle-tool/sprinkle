require 'vlad'

module Sprinkle
  module Actors
    # The Vlad actor is one of the delivery method options available out of the
    # box with Sprinkle. If you have the vlad the deployer gem installed, you 
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
    class Vlad < Actor
      attr_accessor :loaded_recipes #:nodoc:

      def initialize(&block) #:nodoc:
        self.instance_eval &block if block
      end
      
      def servers_for_role?
        raise "The vlad actor needs a maintainer.  "+
        "Please file an issue on github.com/sprinkle-tool/sprinkle if you can help."
      end
      
      def sudo?
        # TODO
        raise
      end
      
      def sudo_command
        "sudo"
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
      
      def install(installer, roles, opts={})
        @installer=installer
        if installer.install_sequence.include?(:TRANSFER)
          process_with_transfer(installer.package.name, installer.install_sequence, roles, opts)
        else
          process(installer.package.name, installer.install_sequence, roles, opts)
        end
      # recast our rake error to the common sprinkle error type
      rescue ::Rake::CommandFailedError => e
        raise Sprinkle::Errors::RemoteCommandFailure.new(installer, {}, e)
      ensure 
        @installer = nil
      end
      
      def verify(verifier, roles, opts={})
        process(verifier.package.name, commands, roles, 
          :suppress_and_return_failures => true)
      end
      
      protected
      
      def process(name, commands, roles, opts ={}) #:nodoc:
        commands = commands.map{|x| "#{sudo_command} #{x}"} if sudo?
        commands = commands.join(' && ')
        puts "executing #{commands}"
        task = remote_task(task_sym(name), :roles => roles) { run commands }
        invoke(task)
      end
      
      def process_with_transfer(name, commands, roles, opts ={}) #:nodoc:
        raise "cant do non recursive file transfers, sorry" if opts[:recursive] == false
        commands = commands.map{|x| x == :TRANSFER ? x : "sudo #{x}" } if sudo?
        i = commands.index(:TRANSFER)
        before = commands.first(i).join(" && ")
        after = commands.last(commands.size-i+1).join(" && ")
        inst = @installer
        task = remote_task(task_sym(name), :roles => roles) do
          run before unless before.empty?
          rsync inst.sourcepath, inst.destination
          run after unless after.empty?
        end
        invoke(task)
      end
      
      def invoke(t)
        t.invoke
        return true
      rescue ::Rake::CommandFailedError => e
        return false if opts[:suppress_and_return_failures]
        # Reraise error if we're not suppressing it
        raise e        
      end

      private

        def task_sym(name)
          "install_#{name.to_task_name}".to_sym
        end
    end
  end
end
