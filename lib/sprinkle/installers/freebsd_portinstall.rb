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
      
      api do
        def freebsd_portinstall(port, options={}, &block)
          install FreebsdPortinstall.new(self, port, options, &block)
        end
      end

      def initialize(parent, port, options={}, &block) #:nodoc:
        super parent, options, &block
        @port = port
      end

      protected

        def install_commands #:nodoc:
          "portinstall --batch #{@port}"
        end

    end
  end
end
