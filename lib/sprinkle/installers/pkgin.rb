module Sprinkle
  module Installers
    # The pkgin installer installs pkgsrc packages on Mac OS X.
    #
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     pkgin 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     pkgin %w(magic_beans magic_sauce)
    #   end
    #
    class Pkgin < PackageInstaller

      ##
      # installs pkgsrc binary packages passed
      # :method: pkgin
      # :call-seq: pkgin(*packages)
      auto_api

      verify_api do
        def has_pkgin(package)
          @commands << "pkgin list | grep -E '^#{@package_name}-'"
        end
      end

    protected

      def install_commands #:nodoc:
        "#{sudo_cmd}pkgin -y install #{@packages.join(' ')}"
      end
    end
  end
end
