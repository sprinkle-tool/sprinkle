module Sprinkle
  module Installers
    class Pacman < Installer
      attr_accessor :packages

      def initialize(parent, *packages, &block)
        super parent, options, &block

        packages = [packages] unless packages.is_a?(Array)
        packages.flatten!


        @packages = packages
      end

      protected

      def install_commands
        "pacman -Sy #{@packages.join(' ')} --no-confirm --needed"  
      end
    end
  end
end
