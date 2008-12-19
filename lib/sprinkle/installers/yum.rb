module Sprinkle
  module Installers
    # = Yum Package Installer
    #
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
    # You may also specify multiple rpms as an array:
    #
    #   package :magic_beans do
    #     yum %w(magic_beans magic_sauce)
    #   end
    class Yum < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_commands #:nodoc:
          "yum install #{@packages.join(' ')} -y"
        end

    end
  end
end
