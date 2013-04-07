module Sprinkle
  module Installers
    # The pacman installer installs Pacman packages
    class Pacman < PackageInstaller
      
      auto_api

      protected

      def install_commands #:nodoc:
        "pacman -Sy #{@packages.join(' ')} --no-confirm --needed"  
      end
    end
  end
end
