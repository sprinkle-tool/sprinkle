module Sprinkle
  module Installers
    class Group < Installer
      def initialize(package, groupname, options, &block)
        super package, &block
        @groupname = groupname
        @options = options
      end
      protected 
      def install_commands
        "addgroup #{@options[:flags]} #{@groupname}"
      end
    end
  end
end
