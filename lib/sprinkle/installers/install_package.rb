module Sprinkle
  module Installers
    class InstallPackage < Installer
      cattr_accessor :installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        if packages.is_a?(Array) && packages.first.is_a?(Array)
          packages = packages.first
        else
          packages = [packages] unless packages.is_a? Array
        end

        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        case installer
          when :smart
            "smart install #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/smart-sprinkle"
          when :yum
            "yum install #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/yum-sprinkle"
          else
            raise "Unknown InstallPackage.installer"
        end
      end
    end

    class UninstallPackage < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, packages, &block) #:nodoc:
        super parent, &block
        if packages.is_a?(Array) && packages.first.is_a?(Array)
          packages = packages.first
        else
          packages = [packages] unless packages.is_a? Array
        end

        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        case Sprinkle::Installers::InstallPackage.installer
          when :smart
            "smart remove #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/smart-sprinkle"
          when :yum
            "yum erase #{@packages.join(' ')} -y 2>&1 | tee -a /var/log/yum-sprinkle"
          else
            raise "Unknown InstallPackage.installer"
        end
      end
    end
  end
end

module Sprinkle
  module Package
    class Package
      def install_package(*names, &block) #:nodoc:
        ActiveSupport::Deprecation.warn("install_package will be removed from sprinkle 0.8, please use yum or smart installers instead.")
        @installers << Sprinkle::Installers::InstallPackage.new(self, names, &block)
      end

      def uninstall_package(*names, &block) #:nodoc:
        ActiveSupport::Deprecation.warn("uninstall_package will be removed from sprinkle 0.8, please use yum or smart installers instead.")
        @installers << Sprinkle::Installers::UninstallPackage.new(self, names, &block)
      end

      alias_method :install_packages, :install_package #:nodoc:
      alias_method :uninstall_packages, :uninstall_package #:nodoc:
    end
  end
end

