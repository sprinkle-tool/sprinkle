module Sprinkle
  module Installers
    class Installer
      attr_accessor :delivery

      def initialize(package, &block)
        @package = package
        @options = {}
        self.instance_eval(&block) if block
      end
      
      def defaults(deployment)
        defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
        self.instance_eval(&defaults) if defaults
        @delivery = deployment.style
      end
      
      def process(roles)
        raise 'Unknown command delivery target' unless @delivery
        
        if Sprinkle::OPTIONS[:testing]
          puts "TESTING: #{@package.name} install sequence: #{install_sequence} for roles: #{roles}"
        else
          @delivery.process(@package.name, install_sequence, roles)
        end
      end
      
      def method_missing(sym, *args, &block)
        unless args.empty? # mutate if not set
          @options[sym] = *args unless @options[sym]
        end
        
        result = @options[sym] || @package.options[sym] # try the parents options if unknown
      end
      
      protected
      
        def install_sequence
          raise 'Concrete installers implement this to specify commands to run to install their respective packages'
        end
    end
  end
end
