module Sprinkle
  module Actors
    
    class RemoteCommandFailure < PrettyFailure #:nodoc:
      
      def print_summary
        summary
        log "Command", @details[:command]
        log "STDERR", @details[:error]
        log "STDOUT", @details[:stdout] unless @details[:stdout].blank?
      end
      
      def summary
        boxed("Package '#{@installer.package.name}' returned error code #{@details[:code]}.")
      end      
      
    end
    
  end
end