module Sprinkle
  module Installers
    class Smart < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        packages = [packages] unless packages.is_a? Array
        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        "smart install #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/smart-sprinkle"
      end
    end
  end
end

module Sprinkle
  module Package
    class Package
      def smart(*names, &block)
        @installer = Sprinkle::Installers::Smart.new(self, *names, &block)
      end
    end
  end
end