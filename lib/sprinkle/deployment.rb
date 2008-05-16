module Sprinkle
  module Deployment
    def deployment(&block)
      @deployment = Deployment.new(&block)
    end
    
    class Deployment
      attr_accessor :style, :defaults
    
      def initialize(&block)
        @defaults = {}
        self.instance_eval(&block)
      end
    
      def delivery(type)
        @style = Actors.const_get(type.to_s.titleize).new
      end
    
      def source(&block)
        @defaults[:source] = block
      end
      
      def process
        POLICIES.each do |policy|
          policy.process(self)
        end
      end
    end
  end
end
