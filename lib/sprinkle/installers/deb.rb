module Sprinkle
  module Installers
    # The Deb installer installs deb packages sourced from a remote URL
    #
    # == Example Usage
    #
    # Installing the magic_beans deb.
    #
    #   package :magic_beans do
    #     deb 'http://debs.example.com/magic_beans.deb'
    #   end
    #
    class Deb < PackageInstaller

      ##
      # install deb packages from an external URL
      # :call-seq:
      #   deb(*package_urls)
      api do
        def deb(url, options = {}, &block)
          install Deb.new(self, url, options, &block)
        end
      end

      attr_accessor :url #:nodoc:

      def initialize(parent, url, options = {}, &block) #:nodoc:
        super parent, options, &block
        @url = url
      end

      protected

        def install_commands #:nodoc:
          [
            "wget -cq --directory-prefix=/tmp #{@url}",
            "#{sudo_cmd}dpkg -i /tmp/#{package_name(@url)}"
          ]
        end

      private

        def package_name(url)
          url.split('/').last
        end

    end
  end
end
