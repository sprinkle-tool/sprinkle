module Sprinkle
  module Installers
    # The Yum package installer installs RPM packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans RPM via Yum. Its all the craze these days.
    #
    #   package :magic_beans do
    #     yum 'magic_beans'
    #   end
    #
    # You may also specify multiple rpms as arguments or an array:
    #
    #   package :magic_beans do
    #     yum "magic_beans", "magic_sauce"
    #   end
    class Yum < PackageInstaller

      protected

        def install_commands #:nodoc:
          "yum install #{@packages.join(' ')} -y"
        end

    end
  end
end
