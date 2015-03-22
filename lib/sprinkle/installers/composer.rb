module Sprinkle
  module Installers
    # The composer package installer installs PHP packages.
    #
    #
    # == Example Usage
    #
    # A simple installation:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     composer 'magic_beans'
    #   end
    class Composer < Installer

      api do
        def composer(name, options = {}, &block)
          install Composer.new(self, name, options, &block)
        end
      end

      attr_accessor :composer #:nodoc:

      def initialize(parent, composer, options = {}, &block) #:nodoc:
        super parent, options, &block
        @composer = composer
      end


      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}composer global require '#{composer}'"
        end

    end
  end
end
