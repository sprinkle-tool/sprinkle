module Sprinkle
  module Installers
    class Pacman < Installer
      attr_accessor :packages

      def initialize(parent, *packages, &block)
        packages.flatten!


        super parent, options, &block

        @packages = packages
      end

      protected

      def install_commands
        "pacman -Sy --no-confirm #{@packages.join(' ')}"  
      end
    end
  end
end
