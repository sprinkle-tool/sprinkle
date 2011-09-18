module Sprinkle
  module Actors
    
    class RemoteCommandFailure < StandardError #:nodoc:
      
      def initialize(installer, details)
        @installer = installer
        @details = details
      end
      
      def print_summary
        summary
        log "Command", @details[:command]
        log "STDERR", @details[:error]
        log "STDOUT", @details[:stdout] unless @details[:stdout].blank?
      end
      
      def summary
        boxed("Package '#{@installer.package.name}' returned error code #{@details[:code]}.")
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