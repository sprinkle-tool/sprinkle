module Sprinkle
  module Installers
    # = Thor Installer
    #
    # This installer runs a thor task.
    # 
    # == Example Usage
    #
    # The following example runs the command "thor spec" on
    # the remote server.
    #
    #   package :spec do
    #     thor 'spec'
    #   end
    # 
    # Specify a Thorfile with the :thorfile option.
    #
    #   package :spec do
    #     thor 'spec', :file => "/var/setup/Thorfile"
    #   end
    class Thor < Sprinkle::Installer::Rake
      
      api do
        def thor(task, options = {}, &block)
          install Thor.new(self, task, options, &block)
        end  
      end
      
      protected

      def executable #:nodoc:
        "thor"
      end
      
      def taskfile #:nodoc:
        file = @options[:thorfile] || @options[:file] 
        file ? "-f #{file} " : ""
      end

    end
  end
end
