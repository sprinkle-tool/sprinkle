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
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     pip %w(magic_beans magic_sauce)
    #   end
    #
    class Pip < Installer

      ##
      # installs the pip packages passed
      # :method: pip
      # :call-seq: pip(*packages)
      auto_api

      verify_api do
        def has_pip(package)
          @commands << "pip show #{package} | fgrep Name"
        end
      end

      protected

        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}pip install #{@packages.join(' ')}"
        end

    end
  end
end
