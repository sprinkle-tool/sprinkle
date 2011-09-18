module Sprinkle
	module Installers
		class Runner < Installer
			attr_accessor :cmd #:nodoc:

			def initialize(parent, cmd, &block) #:nodoc:
			  super parent, {}, &block
				@cmd = cmd
			end

			protected
				
				def install_commands #:nodoc:
					@cmd
				end
		end
	end
end
