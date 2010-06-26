module Sprinkle
	module Installers
		class Runner < Installer
			attr_accessor :cmd #:nodoc:

			def initialize(parent, cmd) #:nodoc:
				super parent
				@cmd = cmd
			end

			protected
				
				def install_commands #:nodoc:
					@cmd
				end
		end
	end
end
