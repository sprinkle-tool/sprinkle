module Sprinkle
  module Installers
    # = Mac OS X Port Installer (macports)
    #
    # The Port installer installs macports ports.
    # 
    # == Example Usage
    #
    # Installing the magic_beans port.
    #
    #   package :magic_beans do
    #     mac_port 'magic/magic_beans'
    #   end
    #
    class MacPort < Installer
      attr_accessor :port #:nodoc:

      def initialize(parent, port, &block) #:nodoc:
        super parent, &block
        @port = port
      end

      protected

        def install_commands #:nodoc:
          "port install #{@port}"
        end

    end
  end
end