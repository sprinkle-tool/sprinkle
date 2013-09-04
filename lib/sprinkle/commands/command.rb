module Sprinkle
  module Commands
    class Command
      
      def initialize(str, opts = {})
        @sudo = opts[:sudo]
        @str = str
        # this is a dummy class for now, not intended to be used directly
        raise
      end
      
      def sudo?
        @sudo
      end
      
      def string
        # TODO: sudo
        @str
      end
      
    end
  end
end