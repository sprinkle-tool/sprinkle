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
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     go %w(magic_beans magic_sauce)
    #   end
    #
    class Go < PackageInstaller

      ##
      # installs the Go packages passed
      # :method: go
      # :call-seq: go(*packages)
      auto_api :go

      protected

        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}go get #{@packages.join(' ')}"
        end

    end
  end
end
