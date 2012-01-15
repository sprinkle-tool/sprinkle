module Sprinkle
  	module Installers

  		class Pear < Installer
  			attr_accessor :package_name
        
        api do
          def pear(package, &block)
            install Sprinkle::Installers::Pear.new(self, package, &block)
          end
        end

  			def initialize(parent, package_name, &block) #:nodoc:
  				super parent, &block
  				@package_name = package_name
  			end

  			protected
  				def install_commands #:nodoc:
  					"pear install --alldeps #{@package_name}"
  				end

  		end
	end
end
