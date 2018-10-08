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
    #     composer 'magic/beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     composer %w(magic/beans magic/sauce)
    #   end
    #
    class Composer < Installer

      ##
      # installs PHP packagists passed
      # :method: composer
      # :call-seq: composer(*packages)
      auto_api

      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}composer global require #{@packages.join(' ')}"
        end

    end
  end
end
