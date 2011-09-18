module Sprinkle
  module Installers
    class Smart < PackageInstaller

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
        @installers << Sprinkle::Installers::Smart.new(self, *names, &block)
      end
    end
  end
end