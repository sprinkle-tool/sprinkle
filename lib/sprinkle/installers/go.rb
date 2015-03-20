module Sprinkle
  module Installers
    # The go package installer installs Go package.
    #
    #
    # == Example Usage
    #
    # A simple installation:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     go 'magic_beans'
    #   end
    class Go < Installer

      api do
        def go(name, options = {}, &block)
          install Go.new(self, name, options, &block)
        end
      end

      attr_accessor :go #:nodoc:

      def initialize(parent, go, options = {}, &block) #:nodoc:
        super parent, options, &block
        @go = go
      end


      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}go get #{go}"
        end

    end
  end
end
