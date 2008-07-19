module Sprinkle
  module Installers
    # = Rake Installer
    #
    # This installer runs a rake command.
    # 
    # == Example Usage
    #
    # The following example runs the command "rake spec" on
    # the remote server.
    #
    #   package :spec do
    #     rake 'spec'
    #   end
    # 
    class Rake < Installer
      def initialize(parent, commands = [], &block) #:nodoc:
        super parent, &block
        @commands = commands
      end

      protected

        def install_commands #:nodoc:
          "rake #{@commands.join(' ')}"
        end

    end
  end
end
