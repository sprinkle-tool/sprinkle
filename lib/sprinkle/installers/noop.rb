module Sprinkle
  module Installers
    # = Noop Installer
    #
    # This installer does nothing, it's simply useful for running pre / post hooks by themselves. 
    # 
    class Noop < Installer
      def initialize(parent, &block) #:nodoc:
        super parent, {}, &block
      end

      protected

        def install_commands #:nodoc:
          ''
        end

    end
  end
end
