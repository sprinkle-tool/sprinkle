module Sprinkle
  module Installers
    class Rpm < Installer
      attr_accessor :packages

      def initialize(parent, packages, &block)
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

        def install_commands
          "rpm -Uvh #{@packages.join(' ')}"
        end

    end
  end
end
