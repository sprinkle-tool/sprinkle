module Sprinkle
  module Installers
    class Apt < Installer
      def initialize(parent, packages, &block)
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end
      
      protected
      
        def install_sequence
          "apt-get -y install #{@packages.join(' ')}"
        end
    end
  end
end