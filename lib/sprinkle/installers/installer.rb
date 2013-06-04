module Sprinkle
  # Installers are where the bulk of the work in Sprinkle happens.  Installers are
  # the building blocks of packages.  Typically each unique type of install
  # command has it's own installer class.
  # 
  module Installers
    # The base class which all installers must subclass, this class makes
    # sure all installers share some general features, which are outlined
    # below. 
    #
    # = Pre/Post Installation Hooks
    # 
    # With all installation methods you have the ability to specify multiple
    # pre/post installation hooks. This gives you the ability to specify
    # commands to run before and after an installation takes place. 
    # There are three ways to specify a pre/post hook.
    
    # Note about sudo:
    # When using the Capistrano actor all commands by default are run using
    # sudo (unless your Capfile includes "set :use_sudo, false").  If you wish 
    # to use sudo periodically with "set :user_sudo, false" or with an actor 
    # other than Capistrano then you can just append it to your command. Some 
    # installers (transfer) also support a :sudo option, so check each 
    # installer for details.
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
      include Sprinkle::Attributes      
      
      attr_accessor :delivery, :package, :options, :pre, :post #:nodoc:

      def initialize(package, options = {}, &block) #:nodoc:
        @package = package
        @options = options || {}
        @pre = {}; @post = {}
        self.instance_eval(&block) if block
      end
            
      attributes :prefix, :archives, :builds
      
      class << self
        def subclasses
          @subclasses ||= []
        end
        
        def api(&block)
          Sprinkle::Package::Package.add_api &block
        end
        
        def verify_api(&block)
          Sprinkle::Verify.class_eval &block
        end

        def inherited(base)
          subclasses << base
        end
      end
            
      def sudo_cmd
        return "#{@delivery.try(:sudo_command) || "sudo"} " if sudo?
      end

      def sudo?
        options[:sudo] or package.sudo? or @delivery.try(:sudo?)
      end

      def escape_shell_arg(str)
        str.gsub("'", "'\\\\''").gsub("\n", '\n')
      end

      def pre(stage, *commands, &block)
        options = commands.extract_options!
        commands.concat(commands_from_block(block))
        @pre[stage] ||= []
        if options.fetch(:prepend, false)
          @pre[stage].unshift(commands)
        else
          @pre[stage] << commands
        end
      end

      def post(stage, *commands, &block)
        options = commands.extract_options!
        commands.concat(commands_from_block(block))
        @post[stage] ||= []
        if options.fetch(:prepend, false)
          @post[stage].unshift(commands)
        else
          @post[stage] << commands
        end
      end
      
      def commands_from_block(block)
        return [] unless block
        out = nil
        diff = @package.with_private_install_queue do
          out = block.call
        end
        diff.empty? ? out : diff.map {|x| x.install_sequence }
      end
      
      def method_missing(method, *args, &block)
        if package.class.installer_methods.include?(method)
          @package.send(method, *args, &block)
        else
          super(method, *args, &block)
        end
      end
      
      def per_host?
        return false
        @per_host
      end
      
      # Called right before an installer is exected, can be used for logging
      # and announcing what is about to happen
      def announce; end

      def process(roles) #:nodoc:
        if logger.debug?
          sequence = install_sequence; sequence = sequence.join('; ') if sequence.is_a? Array
          logger.debug "#{@package.name} install sequence: #{sequence} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
          logger.debug "    --> Running #{self.class.name} for roles: #{roles}"
          @delivery.install(self, roles, :per_host => per_host?)
        end
      end

        # More complicated installers that have different stages, and require pre/post commands
        # within stages can override install_sequence and take complete control of the install
        # command sequence construction (eg. source based installer).
        def install_sequence
          commands = pre_commands(:install) + [ install_commands ] + post_commands(:install)
          commands.flatten
        end
        
      protected
      
        def log(t, level=:info)
          logger.send(level, t)
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
