module Sprinkle
  module Installers
    # = Homebrew Package Installer
    #
    # The Homebrew package installer uses the +brew+ command to install
    # packages on OSX.
    # 
    # == Example Usage
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     brew 'magic_beans_package'
    #   end
    #
    class Brew < Installer
      attr_accessor :formulas #:nodoc:

      def initialize(parent, *formulas, &block) #:nodoc:
        formulas.flatten!
        
        super parent, &block
        
        @formulas = formulas
      end

      protected

        def install_commands #:nodoc:
          "brew install #{@formulas.join(' ')}"
        end

    end
  end
end
