module Sprinkle
  module Installers
    # The MacPort installer installs macports ports.
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
    #
    # Before MacPorts packages can be installed, the PATH
    # environment variable probably has to be changed so
    # Sprinkle can find the /opt/local/bin/port executable
    #
    # You must set PATH in ~/.ssh/environment on the remote
    # system and enable 'PermitUserEnvironment yes' in /etc/sshd_config
    #
    class MacPort < Installer
      
      api do
        def mac_port(port, options={}, &block)
          install Sprinkle::Installers::MacPort.new(self, port, options, &block)
        end
      end
      
      attr_accessor :port #:nodoc:

      def initialize(parent, port, options = {}, &block) #:nodoc:
        super parent, options, &block
        @port = port
      end

      protected

        def install_commands #:nodoc:
          "port install #{@port}"
        end

    end
  end
end