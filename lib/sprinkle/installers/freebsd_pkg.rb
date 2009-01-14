module Sprinkle
  module Installers
    # = FreeBSD Package Installer
    #
    # The Pkg package installer installs FreeBSD packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     freebsd_pkg 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     freebsd_pkg %w(magic_beans magic_sauce)
    #   end
    class FreebsdPkg < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_commands #:nodoc:
          "pkg_add -r #{@packages.join(' ')}"
        end

    end
  end
end
