module Sprinkle
  # = Verify Blocks
  #
  # As documented in Sprinkle::Package, you may define a block on a package
  # which verifies that a package was installed correctly. If this verification
  # block fails, Sprinkle will stop the script gracefully, raising the error.
  # 
  # In addition to checking post install if it was successfully, verification
  # blocks are also run before an install to see if a package is <em>already</em>
  # installed. If this is the case, the package is skipped and Sprinkle continues
  # with the next package. This behavior can be overriden by setting the -f flag on
  # the sprinkle script or setting Sprinkle::OPTIONS[:force] to true if you're
  # using sprinkle programmatically. 
  #
  # == An Example
  #
  # The following verifies that rails was installed correctly be checking to see
  # if the 'rails' command is available on the command line:
  #
  #   package :rails do
  #     gem 'rails'
  #     
  #     verify do
  #       has_executable 'rails'
  #     end
  #   end
  #
  # == Available Verifiers
  #
  # There are a variety of available methods for use in the verification block.
  # The standard methods are defined in the Sprinkle::Verifiers module, so see
  # their corresponding documentation.
  #
  # == Custom Verifiers
  # 
  # If you feel that the built-in verifiers do not offer a certain aspect of
  # verification which you need, you may create your own verifier! Simply wrap
  # any method in a module which you want to use:
  #
  #   module MagicBeansVerifier
  #     def has_magic_beans(sauce)
  #       @commands << '[ -z "`echo $' + sauce + '`"]'
  #     end
  #   end
  #
  # The method can append as many commands as it wishes to the @commands array. 
  # These commands will be run on the remote server and <b>MUST</b> give an
  # exit status of 0 if successful or other if unsuccessful.
  #
  # To register your verifier, call the register method on Sprinkle::Verify:
  #
  #   Sprinkle::Verify.register(MagicBeansVerifier)
  #
  # And now you may use it like any other verifier:
  #
  #   package :magic_beans do
  #     gem 'magic_beans'
  #     
  #     verify { has_magic_beans('ranch') }
  #   end
  class Verify
    include Sprinkle::Attributes
    include Sprinkle::Package::Rendering::Helpers
    include Sprinkle::Sudo
    attr_accessor :package, :description, :commands, :options #:nodoc:
    
    delegate :opts, :to => :package
    delegate :args, :to => :package
    delegate :version, :to => :package
    delegate :description, :to => :package

    class <<self
      # Register a verification module
      def register(new_module)
        class_eval { include new_module }
      end
    end
    
    attributes :padding
    
    def initialize(package, description = '', &block) #:nodoc:
      raise 'Verify requires a block.' unless block
      
      @package = package
      @description = description
      @commands = []
      @options ||= {}
      @options[:padding] = 4
      @delivery = nil
      
      self.instance_eval(&block)
    end
    
    def runner(*cmds)
      ActiveSupport::Deprecation.warn 
        "runner inside verify is depreciated and will removed in the future\n" +
        "use runs_without_error instead."
      runs_without_error(*cmds)
    end
    
    def runs_without_error(*cmds)
      @commands += cmds
    end
    
    def process(roles, pre = false) #:nodoc:
      description = @description.empty? ? " (#{@package.name})" : @description
      
      if logger.debug?
        logger.debug "#{@package.name}#{description} verification sequence: #{@commands.join('; ')} for roles: #{roles}\n"
      end
      
      unless Sprinkle::OPTIONS[:testing]
        logger.debug "#{" " * @options[:padding]}--> Verifying #{description}..."
        
        unless @delivery.verify(self, roles)
          # Verification failed, halt sprinkling gracefully.
          raise Sprinkle::VerificationFailed.new(@package, description)
        end
      end
    end
  end
  
  class VerificationFailed < Exception #:nodoc:
    attr_accessor :package, :description
    
    def initialize(package, description)
      super("Verifying #{package.name}#{description} failed.")
      
      @package = package
      @description = description
    end
  end
end
