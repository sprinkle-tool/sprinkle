module Sprinkle
  class Verify
    include Sprinkle::Configurable
    attr_accessor :package, :description, :commands
    
    def initialize(package, description = '', &block)
      raise 'Verify requires a block.' unless block
      
      @package = package
      @description = description
      @commands = []
      @options ||= {}
      @options[:padding] = 4
      
      self.instance_eval(&block)
    end
    
    def process(roles, pre = false)
      assert_delivery
      
      description = @description.empty? ? @package.name : @description
      
      if logger.debug?
        logger.debug "#{@package.name}#{description} verification sequence: #{@commands.join('; ')} for roles: #{roles}\n"
      end
      
      unless Sprinkle::OPTIONS[:testing]
        logger.info "#{" " * @options[:padding]}--> Verifying #{description}..."
        
        unless @delivery.process(@package.name, @commands, roles, true)
          # Verification failed, halt sprinkling gracefully.
          raise Sprinkle::VerificationFailed.new(@package, description)
        end
      end
    end
    
    def has_file(path)
      @commands << "test -f #{path}"
    end
    
    def has_directory(dir)
      @commands << "test -d #{dir}"
    end
  end
  
  class VerificationFailed < Exception
    attr_accessor :package, :description
    
    def initialize(package, description)
      super("Verifying #{package.name}#{description} failed.")
      
      @package = package
      @description = description
    end
  end
end