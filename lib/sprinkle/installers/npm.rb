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
        def npm(package, options={}, &block)
          install Npm.new(self, package, options, &block)
        end
      end

      verify_api do
        def has_npm(package)
          @commands << "npm --global list | grep -F \"#{package}@\""
        end
      end

      def initialize(parent, package_name, options={}, &block) #:nodoc:
        super parent, options, &block
        @package_name = package_name
      end

    protected

      def install_commands #:nodoc:
        "#{sudo_cmd}npm install --global #{@package_name}"
      end

    end
  end
end
