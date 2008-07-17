module Sprinkle
  module Actors
    class Vlad
      require 'vlad'
      attr_accessor :loaded_recipes

      def initialize(&block)
        self.instance_eval &block if block
      end

      def script(name)
        @loaded_recipes ||= []
        self.load name
        @loaded_recipes << script
      end

      def process(name, commands, roles, suppress_and_return_failures = false)
        commands = commands.join ' && ' if commands.is_a? Array
        t = remote_task(task_sym(name), :roles => roles) { run commands }
        
        begin
          t.invoke
          return true
        rescue ::Vlad::CommandFailedError => e
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
