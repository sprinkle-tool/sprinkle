module Sprinkle
  module Installers
    # = Noop Installer
    #
    # This installer does nothing, it's simply useful for running pre / post hooks by themselves. 
    # 
    class Noop < Installer
      def initialize(parent, name, options, &block) #:nodoc:
        super parent, {}, &block
      end

      protected

        def install_commands #:nodoc:
          'echo noop'
        end

    end
  end
end
