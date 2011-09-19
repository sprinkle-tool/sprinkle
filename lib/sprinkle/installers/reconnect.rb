module Sprinkle
  module Installers
    # Disconnects and reconnects the remote SSH session, you might want to do this 
    # after pushing a file that would affect the local shell environment
    #
    # == Example Usage
    #
    #   package :download_with_proxy do
    #     push_text proxy_config, "/etc/environment", :sudo => true
    #     reconnect
    #     source "http://someurlthatneedstheproxy.com/installer.tar.gz"
    #   end
    class Reconnect < Installer

      # :RECONNECT is a symbol that the actors understand to mean to drop
      # and reestablish any SSH conncetions they have open
      def install_commands #:nodoc:
        :RECONNECT
      end

    end
  end
end