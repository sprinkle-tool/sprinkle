module Sprinkle
  module Installers
    # This is a abstract class installer that most all the package installers
    # inherit from (deb, *BSD pkg, rpm, etc)
    class PackageInstaller < Installer
      
      attr_accessor :packages #:nodoc:

      def initialize(parent, *packages, &block) #:nodoc:
        options = packages.extract_options!
        super parent, options, &block
        @packages = [*packages].flatten
      end
      

    end
  end
end
