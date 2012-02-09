module Sprinkle
  module Installers
    # = Aptitude Package Installer
    #
    # The Aptitude package installer installs packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     aptitude 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     aptitude %w(magic_beans magic_sauce)
    #   end
    class Aptitude < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_commands #:nodoc:
          "aptitude -y install #{@packages.join(' ')}"
        end

    end
  end
end
