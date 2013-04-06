module Sprinkle
  module Errors
    
    class RemoteCommandFailure < PrettyFailure #:nodoc:
      
      def print_summary
        summary
        log "Command", @details[:command]
        # capistrano returns this
        log "Hosts", @details[:hosts] if @details[:hosts]
        # ssh actor returns error and stdout outputs
        log "STDERR", @details[:error] unless @details[:error].blank?
        log "STDOUT", @details[:stdout] unless @details[:stdout].blank?
        log "Actor error message", @details[:message] if @details[:message]
      end
      
      def summary
        boxed("Package '#{@installer.package.name}' returned error code #{@details[:code]}.")
      end      
      
    end
    
  end
end