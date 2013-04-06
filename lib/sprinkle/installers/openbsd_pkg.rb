module Sprinkle
  module Installers
    # The OpenBSD package installer installs OpenBSD packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     openbsd_pkg 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     openbsd_pkg %w(magic_beans magic_sauce)
    #   end
    #
    # == Notes
    # Before OpenBSD packages can be installed, the PKG_PATH
    # environment variable must be set.
    #
    # You must set PKG_PATH in ~/.ssh/environment on the remote
    # system and enable 'PermitUserEnvironment yes' in /etc/ssh/sshd_config
    # 
    # For help on PKG_PATH see section 15.2.2 of the OpenBSD FAQ 
    # (http://www.openbsd.org/faq/faq15.html)
    class OpenbsdPkg < PackageInstaller

      protected

        def install_commands #:nodoc:
          "pkg_add #{@packages.join(' ')}"
        end

    end
  end
end
