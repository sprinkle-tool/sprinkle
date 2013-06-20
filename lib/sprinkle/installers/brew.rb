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
    #     brew 'ntp'
    #
    #     verify { has_brew 'ntp' }
    #
    #   end
    #
    class Brew < PackageInstaller

      api do
        def brew(*names, &block)
          recommends :homebrew
          install_package(*names, &block)
        end
      end
      
      verify_api do
        def has_brew(package)
          @commands << "brew list | grep  #{package}"
        end
      end

      protected

        def install_commands #:nodoc:
          "brew install #{@packages.join(' ')}"
        end

    end
  end
end
