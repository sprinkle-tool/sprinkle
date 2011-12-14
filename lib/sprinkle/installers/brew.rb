module Sprinkle
  module Installers
    # = Homebrew Package Installer
    #
    # The Homebrew package installer uses the +brew+ command to install
    # packages on OSX.
    # 
    # == Example Usage
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     brew 'magic_beans_package'
    #   end
    #
    class Brew < PackageInstaller

      protected

        def install_commands #:nodoc:
          "brew install #{@packages.join(' ')}"
        end

    end
  end
end
