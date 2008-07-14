module Sprinkle
  module Installers
    class Apt < Installer
      attr_accessor :packages, :command

      def initialize(parent, *packages, &block)
        super parent, &block
        packages.flatten!
        @command = 'install'
        if packages.first == :build_dep
          packages.shift
          @command = 'build-dep'
        end        
        @packages = packages
      end

      protected

        def install_commands
          "DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get -qyu #{command} #{@packages.join(' ')}"
        end

    end
  end
end
