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
        raise 'No delivery mechanism defined' unless @style
      end

      def delivery(type, &block)
        @style = Actors.const_get(type.to_s.titleize).new &block
      end

      def method_missing(sym, *args, &block)
        @defaults[sym] = block
      end

      def respond_to?(sym); !!@defaults[sym]; end

      def process
        POLICIES.each do |policy|
          policy.process(self)
        end
      end
    end
  end
end
