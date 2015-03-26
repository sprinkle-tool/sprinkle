module Sprinkle
  module Installers
    # The pip package installer installs Python packages.
    #
    #
    # == Example Usage
    #
    # A simple installation:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     pip 'magic_beans'
    #   end
    class Pip < Installer

      api do
        def pip(name, options = {}, &block)
          install Pip.new(self, name, options, &block)
        end
      end

      attr_accessor :pip #:nodoc:

      def initialize(parent, pip, options = {}, &block) #:nodoc:
        super parent, options, &block
        @pip = pip
      end

      verify_api do
        def has_pip(package)
          @commands << "pip show #{package} | fgrep Name"
        end
      end

      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}pip install #{pip}"
        end

    end
  end
end
