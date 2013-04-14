module Sprinkle
  module Installers
    # This installer runs a rake command.
    # 
    # == Example Usage
    #
    # The following example runs the command "rake spec" on
    # the remote server.  Specify an optional Rakefile with 
    # the :rakefile option.
    #
    #   package :spec do
    #     rake 'spec', :rakefile => "/var/setup/Rakefile"
    #   end
    class Rake < Installer
      
      api do
        def rake(name, options = {}, &block)
          install Rake.new(self, name, options, &block)
        end    
      end
      
      def initialize(parent, commands, options = {}, &block) #:nodoc:
        super parent, options, &block
        @commands = commands
      end

      protected

        def install_commands #:nodoc:
          file = @options[:rakefile] ? "-f #{@options[:rakefile]} " : ""
          "rake #{file}#{@commands}"
        end

    end
  end
end
