module Sprinkle
  module Installers
    # Beware, strange "installer" coming your way.
    #
    # This command installer runs arbitary commands
    #
    # == Example Usage
    #
    # If you user has access to 'sudo' and theres a file that requires
    # priveledges, you can pass :sudo => true 
    #
    class Command < Installer
      attr_reader :command #:nodoc:

      api do
        def command(command, options = {}, &block)
          install Command.new(self, command, options, &block)
        end
      end

      def initialize(parent, command, options={}, &block) #:nodoc:
        super parent, options, &block
        @command = command
      end

      def announce #:nodoc:
        log "--> Running '#{@command}'"
      end

      protected

        def install_commands #:nodoc:
          "#{sudo_cmd}#{@command}"
        end
    end
  end
end
