module Sprinkle
  #--
  # TODO: Possible documentation?
  #++
  module Configurable #:nodoc:
    attr_accessor :delivery
    
    def defaults(deployment)
      defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
      self.instance_eval(&defaults) if defaults
      @delivery = deployment.style
    end
    
    def assert_delivery
      raise 'Unknown command delivery target' unless @delivery
    end
    
    def method_missing(sym, *args, &block)
      unless args.empty? # mutate if not set
        @options ||= {}
        @options[sym] = args unless @options[sym]
      end

      @options[sym] || @package.send(sym, *args, &block) # try the parents options if unknown
    end
    
    def option?(sym)
      !@options[sym].nil?
    end
  end
end