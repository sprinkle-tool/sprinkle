module Sprinkle
  module Installers
    # = FreeBSD Portinstall Installer
    #
    # The Portinstall installer installs FreeBSD ports.
    # It uses the ports-mgmt/portupgrade port to install.
    # Before usage, the ports system must be installed and
    # read on the target operating system.
    # It is recommended to use `portsnap fetch extract` to
    # install the ports system.
    # 
    # == Example Usage
    #
    # Installing the magic_beans port.
    #
    #   package :magic_beans do
    #     freebsd_portinstall 'magic/magic_beans'
    #   end
    #
    class FreebsdPortinstall < Installer
      attr_accessor :port #:nodoc:

      def initialize(parent, port, &block) #:nodoc:
        super parent, &block
        @port = port
      end

      protected

        def install_commands #:nodoc:
          "portinstall --batch #{@port}"
        end

    end
  end
end
