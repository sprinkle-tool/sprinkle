module Sprinkle
  module Installers
    # The pacman installer installs Pacman packages
    class Pacman < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, *packages, &block) #:nodoc:
        super parent, options, &block

        packages = [packages] unless packages.is_a?(Array)
        packages.flatten!

        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        "pacman -Sy #{@packages.join(' ')} --no-confirm --needed"  
      end
    end
  end
end
