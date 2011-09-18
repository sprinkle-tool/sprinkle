module Sprinkle
  module Installers
    # The user installer helps add users.  You may pass flags as an option.
    # 
    # == Example Usage
    #
    #   package :users do
    #     adduser 'admin', :flags => "--disabled-password"
    #   end
    class User < Installer
      def initialize(package, username, options = {}, &block) #:nodoc:
        super package, options, &block
        @username = username
      end
      
      protected 
      
      def install_commands #:nodoc:
        "adduser #{@options[:flags]} #{@username}"
      end
    end
  end
end
