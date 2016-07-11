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
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     luarocks %w(magic_beans magic_sauce)
    #   end
    #
    class LuaRocks < Installer

      ##
      # installs the luarocks passed
      # :method: luarocks
      # :call-seq: luarocks(*packages)
      auto_api

      protected

        def install_commands #:nodoc:
          # `luarocks` does not accept multiple packages.
          cmds = @packages.map { |p| "#{sudo_cmd}luarocks install #{p}" }
          cmd = cmds.join('; ')
        end

    end
  end
end
