module Sprinkle
  module Installers
    class Apt < Installer
      attr_accessor :packages

      def initialize(parent, packages, &block)
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_sequence
          "DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get -qyu install #{@packages.join(' ')}"
        end

    end
  end
end
