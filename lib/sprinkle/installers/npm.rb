module Sprinkle
  module Installers
    # = Npm package Installed
    #
    # Installs an npm module
    #
    # == Example Usage
    #
    #   package :magic_beans do
    #     npm 'grunt'
    #   end
    #
    #   verify { has_npm 'grunt' }
    class Npm < Installer

      attr_accessor :package_name

      api do
        def npm(package, &block)
          install Npm.new(self, package, &block)
        end
      end

      verify_api do
        def has_npm(package)
          @commands << "npm --global list | grep \"#{package}@\""
        end
      end

      def initialize(parent, package_name, &block) #:nodoc:
        super parent, &block
        @package_name = package_name
      end

    protected

      def install_commands #:nodoc:
        "npm install --global #{@package_name}"
      end

    end
  end
end
