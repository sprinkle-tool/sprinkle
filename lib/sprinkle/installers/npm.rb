module Sprinkle
  	module Installers

  		class Npm < Installer
  			attr_accessor :package_name
        
        api do
          def npm(package, &block)
            install Sprinkle::Installers::Npm.new(self, package, &block)
          end
        end

  			def initialize(parent, package_name, &block) #:nodoc:
  				super parent, &block
  				@package_name = package_name
  			end

  			protected
  				def install_commands #:nodoc:
  					"npm install --global #{@package_name}"
  				end

  	end
	end
end
