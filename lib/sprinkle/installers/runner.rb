module Sprinkle
  module Installers
    # The runner installer is great for running a simple command.
    #
    # == Example Usage
    #
    #   package :magic_beans do
    #     runner "make world"
    #   end
    #
    # You can also pass multiple commands as arguments or an array.
    #
    #   package :magic_beans do
    #     runner "make world", "destroy world"
    #     runner [ "make world", "destroy world" ]
    #   end
    #
    class Runner < Installer
      attr_accessor :cmds #:nodoc:

      def initialize(parent, *cmds , &block) #:nodoc:
        super parent, {}, &block
        @cmds = [*cmds].flatten
        raise "you need to specify a command" if cmds.nil?
      end
      
      protected
        
        def install_commands #:nodoc:
          @cmds
        end
    end
  end
end
