module Sprinkle
  module Installers
    # The pkgin installer installs pkgsrc packages on Mac OS X.
    #
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     pkgin 'magic_beans'
    #   end
    #
    class Pkgin < PackageInstaller

      attr_accessor :package_name

      api do
        def pkgin(package, &block)
          install Pkgin.new(self, package, &block)
        end
      end
      verify_api do
        def has_pkgin(package)
          @commands << "pkgin list | egrep '^#{@package_name}-'"
        end
      end
      def initialize(parent, package_name, &block) #:nodoc:
        super parent, &block
        @package_name = package_name
      end

    protected

      def install_commands #:nodoc:
        "sudo /opt/pkg/bin/pkgin -y install #{@package_name}"
      end
    end
  end
end
