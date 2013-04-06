module Sprinkle
  module Installers
    # The FreeBSDPkg installer installs FreeBSD packages.
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
    #
    class FreebsdPkg < PackageInstaller

      protected

        def install_commands #:nodoc:
          "pkg_add -r #{@packages.join(' ')}"
        end

    end
  end
end
