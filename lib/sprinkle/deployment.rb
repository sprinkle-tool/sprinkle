module Sprinkle
  
  def deployment(&block)
    Deployment.new(&block)
  end

  # REVISIT: deployment context - better name?
  class Deployment
    attr_accessor :style, :defaults
    
    def initialize(&block)
      @defaults = {}
      self.instance_eval(&block)
      process
    end
    
    def delivery(type)
      @style = Actors.const_get(type.to_s.titleize).new
    end
    
    def source(&block)
      @defaults[:source] = block
    end
    
    private
    
      def process
        @@policies.each do |policy|
          policy.process(self)
        end
      end
  end

end

