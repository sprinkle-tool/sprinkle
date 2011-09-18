module Sprinkle
  module Actors
    
    class TransferFailure < PrettyFailure #:nodoc:
            
      def self.no_permission(installer,e)
        tf=TransferFailure.new(installer, {}, e)
        tf.details[:error]=e.message
        tf
      end
      
      def print_summary
        summary
        # log "Command", @details[:command]
        log "ERROR", @details[:error]
        if details[:error] =~ /Permission denied/
          log "HINTS", "You may want to try passing the :sudo option to transfer."
        end
      end
      
      def summary
        boxed("Package '#{@installer.package.name}' could not transfer #{@installer.source}")
      end
         
    end
    
  end
end