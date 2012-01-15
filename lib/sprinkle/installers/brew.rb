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

      api do
        def brew(*names, &block)
          @recommends << :homebrew
          install Sprinkle::Installers::Brew.new(self, *names, &block)
        end
      end

      protected

        def install_commands #:nodoc:
          "brew install #{@packages.join(' ')}"
        end

    end
  end
end
