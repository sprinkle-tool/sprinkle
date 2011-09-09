module Sprinkle
  module Installers
    # The base class which all installers must subclass, this class makes
    # sure all installers share some general features, which are outlined
    # below. 
    #
    # = Pre/Post Installation Hooks
    # 
    # With all installation methods you have the ability to specify multiple
    # pre/post installation hooks. This gives you the ability to specify
    # commands to run before and after an installation takes place. All 
    # commands by default are sudo'd so there is no need to include "sudo"
    # in the command itself. There are three ways to specify a pre/post hook.
    # 
    # First, a single command:
    #
    #   pre :install, 'echo "Hello, World!"'
    #   post :install, 'rm -rf /'
    #
    # Second, an array of commands:
    #
    #   commands = ['echo "First"', 'echo "Then Another"']
    #   pre :install, commands
    #   post :install, commands
    #
    # Third, a block which returns either a single or multiple commands:
    #
    #   pre :install do
    #     amount = 7 * 3
    #     "echo 'Before we install, lets plant #{amount} magic beans...'"
    #   end
    #   post :install do
    #     ['echo "Now... let's hope they sprout!", 'echo "Indeed they have!"']
    #   end
    #
    # = Other Pre/Post Hooks
    #
    # Some installation methods actually grant you more fine grained
    # control of when commands are run rather than a blanket pre :install
    # or post :install. If this is the case, it will be documented on
    # the installation method's corresponding documentation page. 
    class Installer
      include Sprinkle::Configurable
      attr_accessor :delivery, :package, :options, :pre, :post #:nodoc:

      def initialize(package, options = {}, &block) #:nodoc:
        @package = package
        @options = options
        @pre = {}; @post = {}
        self.instance_eval(&block) if block
      end

      def pre(stage, *commands)
        @pre[stage] ||= []
        @pre[stage] += commands
        @pre[stage] += [yield] if block_given?
      end

      def post(stage, *commands)
        @post[stage] ||= []
        @post[stage] += commands
        @post[stage] += [yield] if block_given?
      end

      def process(roles) #:nodoc:
        assert_delivery

        if logger.debug?
          sequence = install_sequence; sequence = sequence.join('; ') if sequence.is_a? Array
          logger.debug "#{@package.name} install sequence: #{sequence} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
          logger.info "--> Installing #{package.name} for roles: #{roles}"
          @delivery.process(@package.name, install_sequence, roles)
        end
      end

      protected
        # More complicated installers that have different stages, and require pre/post commands
        # within stages can override install_sequence and take complete control of the install
        # command sequence construction (eg. source based installer).
        def install_sequence
          commands = pre_commands(:install) + [ install_commands ] + post_commands(:install)
          commands.flatten
        end

        # A concrete installer (subclass of this virtual class) must override this method
        # and return the commands it needs to run as either a string or an array. 
        #
        # <b>Overriding this method is required.</b>
        def install_commands
          raise 'Concrete installers implement this to specify commands to run to install their respective packages'
        end

        def pre_commands(stage) #:nodoc:
          dress @pre[stage] || [], :pre
        end

        def post_commands(stage) #:nodoc:
          dress @post[stage] || [], :post
        end

        # Concrete installers (subclasses of this virtual class) can override this method to
        # specify stage-specific (pre-installation, post-installation, etc.) modifications
        # of commands. 
        #
        # An example usage of overriding this would be to prefix all commands for a 
        # certain stage to change to a certain directory. An example is given below:
        #
        #   def dress(commands, stage)
        #     commands.collect { |x| "cd #{magic_beans_path} && #{x}" }
        #   end
        #
        # By default, no modifications are made to the commands.
        def dress(commands, stage); commands; end

    end
  end
end
