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

      def process(name, commands, roles)
        commands = commands.join ' && ' if commands.is_a? Array
        t = remote_task(task_sym(name), :roles => roles) { run commands }
        t.invoke
      end

      private

        def task_sym(name)
          "install_#{name.to_task_name}".to_sym
        end
    end
  end
end
