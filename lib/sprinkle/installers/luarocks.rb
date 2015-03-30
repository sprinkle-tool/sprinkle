module Sprinkle
  module Installers
    # The luarocks package installer installs Lua modules.
    #
    #
    # == Example Usage
    #
    # A simple installation:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     luarocks 'magic_beans'
    #   end
    class LuaRocks < Installer

      api do
        def luarocks(name, options = {}, &block)
          install LuaRocks.new(self, name, options, &block)
        end
      end

      attr_accessor :luarocks #:nodoc:

      def initialize(parent, luarocks, options = {}, &block) #:nodoc:
        super parent, options, &block
        @luarocks = luarocks
      end


      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}luarocks install #{luarocks}"
        end

    end
  end
end
