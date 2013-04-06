module Sprinkle
  module Errors
    
    class PrettyFailure < StandardError #:nodoc:
      
      attr_accessor :details
      
      def initialize(installer, details={}, previous_error=nil)
        @installer = installer
        @details = details
        @previous_error = previous_error
      end
            
      def log(s, o)
        puts s
        puts "-" * (s.length+2)
        puts o
        puts
      end
      
      def boxed(s)
        puts red("-"*54)
        puts red("| #{s.center(50)} |")
        puts red("-"*54)
        puts
      end
      
      private
      
      def color(code, s)
        "\033[%sm%s\033[0m"%[code,s]
      end
      
      def red(s)
        color(31, s)
      end
      
    end
    
  end
end