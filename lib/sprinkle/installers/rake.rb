module Sprinkle
  module Installers
    # This installer runs a rake task.
    # 
    # == Example Usage
    #
    # The following example runs the command "rake spec" on
    # the remote server.  Specify an optional Rakefile with 
    # the :rakefile option.
    #
    #   package :spec do
    #     rake 'spec', :file => "/var/setup/Rakefile"
    #   end
    class Rake < Installer
      
      api do
        def rake(task, options = {}, &block)
          install Rake.new(self, task, options, &block)
        end    
      end
      
      def initialize(parent, commands, options = {}, &block) #:nodoc:
        super parent, options, &block
        @commands = commands
      end

      protected

        def install_commands #:nodoc:
          "#{executable} #{taskfile}#{@commands}"
        end
        
        def executable #:nodoc:
          "rake"
        end
        
        def taskfile #:nodoc:
          file = @options[:rakefile] || @options[:file] 
          file ? "-f #{file} " : ""
        end

    end
  end
end
