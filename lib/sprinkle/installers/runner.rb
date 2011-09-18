module Sprinkle
	module Installers
	  # The runner installer is great for running a single command.
	  #
	  # == Example Usage
    #
    #   package :magic_beans do
    #     runner "make world"
    #   end
    #
		class Runner < Installer
			attr_accessor :cmd #:nodoc:

			def initialize(parent, cmd = nil , &block) #:nodoc:
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
