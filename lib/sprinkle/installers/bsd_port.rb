module Sprinkle
  module Installers
    # = OpenBSD and FreeBSD Port Installer
    #
    # The Port installer installs OpenBSD and FreeBSD ports.
    # Before usage, the ports sytem must be installed and
    # read on the target operating system.
    # 
    # == Example Usage
    #
    # Installing the magic_beans port.
    #
    #   package :magic_beans do
    #     bsd_port 'magic/magic_beans'
    #   end
    #
    class BsdPort < Installer
      attr_accessor :port #:nodoc:

      def initialize(parent, port, &block) #:nodoc:
        super parent, &block
        @port = port
      end

      protected

        def install_commands #:nodoc:
          "sh -c 'cd /usr/ports/#{@port} && make BATCH=yes install clean'"
        end

    end
  end
end