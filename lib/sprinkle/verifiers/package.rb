module Sprinkle
  module Verifiers
    module Package
      Sprinkle::Verify.register(Sprinkle::Verifiers::Package)

      def has_package(*packages)
        if packages.is_a?(Array) && packages.first.is_a?(Array)
          packages = packages.first
        else
          packages = [packages] unless packages.is_a? Array
        end

        packages.each do |pak|
          case Sprinkle::Installers::InstallPackage.installer
            when :yum
              @commands << "[ -n \"`yum list installed #{pak} 2> /dev/null | egrep -e \\\"#{pak}\\\"`\" ]"
            else
              raise "Unknown InstallPackage.installer"
          end
        end
      end

      alias_method :has_packages, :has_package  
    end
  end
end