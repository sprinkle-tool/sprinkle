module Sprinkle
  module Installers
    class Rake < Installer
      def initialize(parent, commands = [], &block)
        super parent, &block
        @commands = commands
      end
      
      protected
      
        def install_sequence
          if @commands
            "rake #{@commands.join(' ')}"
          end
        end
    end
  end
end