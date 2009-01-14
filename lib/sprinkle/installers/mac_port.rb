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
    # == Notes
    # Before MacPorts packages can be installed, the PATH
    # environment variable probably has to be changed so
    # capistrano can find the /opt/local/bin/port executable
    #
    # You must set PATH in ~/.ssh/environment on the remote
    # system and enable 'PermitUserEnvironment yes' in /etc/sshd_config
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