module Sprinkle
  module Installers
    # = Deb Package Installer
    #
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
    class Deb < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_commands #:nodoc:
          [
					"wget -cq --directory-prefix=/tmp #{@packages.join(' ')}", 
					"dpkg -i #{@packages.collect{|p| "/tmp/#{package_name(p)}"}.join(" ")}"
					]
        end
        
      private
      
        def package_name(url)
          url.split('/').last
        end

    end
  end
end
