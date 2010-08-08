module Sprinkle
  module Installers
    class User < Installer
      def initialize(package, username, options, &block)
        super package, &block
        @username=username
        @options =options
      end
      protected 
      def install_commands
        "bash -c '/usr/sbin/adduser #{@options[:flags]} #{@username}"
      end
    end
  end
end
