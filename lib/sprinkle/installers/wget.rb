module Sprinkle
  module Installers
    # The wget package installer downloads file from web.
    #
    # == Example Usage
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     wget 'http://example.com/magic_beans.sh', '/usr/local/bin/magic_beans'
    #   end
    #
    # After downloading, we chmod 755 to magic_beans.
    class Wget < Installer

      api do
        def wget(url, path, options = {}, &block)
          install Wget.new(self, url, path, options, &block)
        end
      end

      attr_accessor :url, :path #:nodoc:

      def initialize(parent, url, path, options = {}, &block) #:nodoc:
        super parent, options, &block
        @url = url
        @path = path
      end


      protected


        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}wget -c -O #{path} #{url} && #{sudo_cmd} chmod 755 #{path}"
        end

    end
  end
end
