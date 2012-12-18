module Sprinkle
  	module Installers

  		class Npm < Installer
  			attr_accessor :package_name

  			def initialize(parent, package_name, &block)
  				super parent, &block
  				@package_name = package_name
  			end

  			protected
  				def install_commands #override
  					"npm install --global #{@package_name}"
  				end

  		end #of class
	end #module
end #module
