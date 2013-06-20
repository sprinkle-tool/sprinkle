module Sprinkle
  module Installers
    # This is a abstract class installer that most all the package installers
    # inherit from (deb, *BSD pkg, rpm, etc)
    class PackageInstaller < Installer
      
      # holds the list of packages to be installed
      attr_accessor :packages 

      def initialize(parent, *packages, &block) #:nodoc:
        options = packages.extract_options!
        super parent, options, &block
        @packages = [*packages].flatten
      end
      
      # automatically sets up the api for package installation based on the class name
      #
      # Apt becomes the method `apt`, etc
      def self.auto_api
        method_name = self.to_s.underscore.split("/").last
        class_name = self.to_s
        api do
          method="def #{method_name}(*names, &block)
            install #{class_name}.new(self, *names, &block)
          end"
          eval(method)
        end
      end
      
      # called by subclasses of PackageInstaller
      def install_package(*names, &block) #:nodoc:
        install Sprinkle::Installers::class.new(self, *names, &block)
      end

    end
  end
end
