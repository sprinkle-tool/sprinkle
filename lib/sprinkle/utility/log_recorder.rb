module Sprinkle
  module Utility #:nodoc:
    class LogRecorder #:nodoc:
      
      attr_accessor :err, :out, :command, :code
      
      def initialize(cmd=nil)
        reset(cmd)
      end
            
      def log(stream, data)
        case stream
          when :err then @err << data
          when :out then @out << data
        end
      end
      
      # hash suitable to pass into a pretty failure details hash
      def hash
        {:error => err, :stdout => out, :command => command, :code => code}
      end
      
      def reset(cmd=nil)
        @command=cmd
        @code=nil
        @err=""
        @out=""        
      end
      
    end
    
  end
end