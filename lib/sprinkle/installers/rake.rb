module Sprinkle
  module Installers
    class Rake < Installer
      def initialize(parent, commands = [], &block)
        super parent, &block
        @commands = commands
      end

      protected

        def install_sequence
          "rake #{@commands.join(' ')}"
        end
    end
  end
end
