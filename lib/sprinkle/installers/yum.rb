module Sprinkle
  module Installers
    # The Yum package installer installs RPM packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans RPM via Yum. Its all the craze these days.
    #
    #   package :magic_beans do
    #     yum 'magic_beans', 'magic_corn'
    #     verify do
    #       has_yum 'magic_beans' 
    #       has_yum 'magic_corn' 
    #     end
    #   end
    #
    # To install a specific version just add that version after the name
    #
    #   package :magic_beans do
    #     yum "magic_beans-3.0" 
    #   end
    class Yum < PackageInstaller

      ##
      # installs the RPM packages passed
      # :method: yum
      # :call-seq: yum(*packages)
      auto_api

      verify_api do
        def has_yum(package)
          @commands << "yum list installed #{package} | grep ^#{package}"
        end
      end

      protected

        def install_commands #:nodoc:
          "yum install #{@packages.join(' ')} -y"
        end

    end
  end
end
