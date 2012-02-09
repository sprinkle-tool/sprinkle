module Sprinkle
  module Installers
    class User < Installer
      def initialize(package, username, options, &block)
        super package, &block
        @username = username
        @options = options
      end
      protected 
      def install_commands
        "useradd #{@options[:flags]} #{@username}"
      end
    end
  end
end
