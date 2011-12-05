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
    #
    # You may also use options.
    #
    #   package :magic_beans do
    #     set_yum_options '--enablerepo=epel --skip-broken'
    #     yum 'magic_beans'
    #   end
    class Yum < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, options, &block) #:nodoc:
        super parent, options, &block
        packages = [packages] unless packages.is_a? Array
        options = [options] unless options.is_a? Array
        @packages = packages
	@options = options
      end

      protected

        def install_commands #:nodoc:
          "bash -c 'yum install #{@options.join(' ')} #{@packages.join(' ')} -y'"
        end

    end
  end
end
