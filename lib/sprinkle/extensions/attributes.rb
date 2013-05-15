module Sprinkle
  module Attributes
    extend ActiveSupport::Concern
    
    included do
      attr_accessor :delivery
    end
    
    def defaults(deployment)
      defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
      self.set_defaults(&defaults) if defaults
      @delivery = deployment.style
    end
    
    def set_defaults(&block)
      before = @options
      @options = {}
      self.instance_eval(&block) if block
      @options = before.reverse_merge(@options)
    end
    
    private 
    
    def read_from_package(m)
      @package.send(m) if @package.respond_to?(m)
    end
    
    def option?(sym)
      !!@options[sym]
    end
    
    module ClassMethods
      
      def attributes(*list)
        list.each do |a|
          define_method a do |*val|
            val=nil if val.empty?
            val ? @options[a] = val.first : @options[a] || read_from_package(a)
          end
        end
      end
      
      def multi_attributes(*list)
        list.each do |a|
          define_method a do |*val|
            val = val.try(:first)
            return @options[a] unless val
            @options[a]||=[]
            val.is_a?(Array) ? @options[a] += val : @options[a] << val
          end
        end
      end
    end

  end
end