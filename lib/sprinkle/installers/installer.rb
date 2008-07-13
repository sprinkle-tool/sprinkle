module Sprinkle
  module Installers
    class Installer
      attr_accessor :delivery, :package, :options, :pre, :post

      def initialize(package, options = {}, &block)
        @package = package
        @options = options
        @pre = {}; @post = {}
        self.instance_eval(&block) if block
      end

      def pre(stage, *commands)
        @pre[stage] ||= []
        @pre[stage] += commands
      end

      def post(stage, *commands)
        @post[stage] ||= []
        @post[stage] += commands
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

        # Installation is separated into two styles that concrete derivative installer classes
        # can implement.
        #
        # Simple installers that issue a single or set of commands can overwride
        # install_commands (eg. apt, gem, rpm). Pre/post install commands are included in this
        # style for free.
        #
        # More complicated installers that have different stages, and require pre/post commands
        # within stages can override install_sequence and take complete control of the install
        # command sequence construction (eg. source based installer).

        def install_sequence
          commands = pre_commands(:install) + [ install_commands ] + post_commands(:install)
          commands.flatten
        end

        def install_commands
          raise 'Concrete installers implement this to specify commands to run to install their respective packages'
        end

        def pre_commands(stage)
          dress @pre[stage] || [], :pre
        end

        def post_commands(stage)
          dress @post[stage] || [], :post
        end

        def dress(commands, stage); commands; end

    end
  end
end
