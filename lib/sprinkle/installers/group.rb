module Sprinkle
  module Installers
    class Group < Installer
      
      api do
        def add_group(group, options={},  &block)
          install Sprinkle::Installers::Group.new(self, group, options, &block)
        end
      end
      
      def initialize(package, groupname, options, &block)
        super package, options, &block
        @groupname = groupname
      end
      
      protected 
      def install_commands
        "addgroup #{@options[:flags]} #{@groupname}"
      end
    end
  end
end
