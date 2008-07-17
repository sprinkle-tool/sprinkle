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
      @options[:failures] = '/tmp'
      
      self.instance_eval(&block)
    end
    
    def process(roles)
      assert_delivery
      
      unless Sprinkle::OPTIONS[:testing]
        logger.info "--> Verifying #{@package.name} for roles: #{roles}"
        @delivery.process(@package.name, @commands, roles).to_s
      end
    end
    
    def has_file(path)
      @commands << "test -f #{path}"
    end
    
    def has_directory(dir)
      @commands << "test -d #{dir}"
    end
  end
end