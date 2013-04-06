module Sprinkle
  	module Installers
      # = Pear package installed
      #
      # Installs the specified pear package
      # 
      # == Example Usage
      #
      #   package :php_stuff do
      #     pear 'PHP_Compat'
      #     verify { has_pear 'PHP_Compat' }
      #   end
  		class Pear < Installer
  			attr_accessor :package_name
        
        api do
          def pear(package, &block)
            install Sprinkle::Installers::Pear.new(self, package, &block)
          end
        end
        
        verify_api do
          def has_pear(package)
            @commands << "pear list | grep \"#{package}\" | grep \"stable\""
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
