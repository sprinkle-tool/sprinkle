module Sprinkle
  module Installers
    class Smart < PackageInstaller
      
      api do
        def smart(*names, &block)
          install Sprinkle::Installers::Smart.new(self, *names, &block)
        end
      end

      protected

      def install_commands #:nodoc:
        "smart install #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/smart-sprinkle"
      end
    end
  end
end