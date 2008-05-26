module Sprinkle
  module Installers
    class Installer
      attr_accessor :delivery, :package, :options

      def initialize(package, options = {}, &block)
        @package = package
        @options = options
        self.instance_eval(&block) if block
      end

      def defaults(deployment)
        defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
        self.instance_eval(&defaults) if defaults
        @delivery = deployment.style
      end

      def process(roles)
        raise 'Unknown command delivery target' unless @delivery

        if logger.debug?
          sequence = install_sequence; sequence = sequence.join('; ') if sequence.is_a? Array
          logger.debug "#{@package.name} install sequence: #{sequence} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
          logger.info "--> Installing #{package.name} for roles: #{roles}"
          @delivery.process(@package.name, install_sequence, roles)
        end
      end

      def method_missing(sym, *args, &block)
        unless args.empty? # mutate if not set
          @options[sym] = *args unless @options[sym]
        end

        @options[sym] || @package.send(sym, *args, &block) # try the parents options if unknown
      end

      protected

        def install_sequence
          raise 'Concrete installers implement this to specify commands to run to install their respective packages'
        end
    end
  end
end
