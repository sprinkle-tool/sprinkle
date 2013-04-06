module Sprinkle
  module Installers
    # = Thor Installer
    #
    # This installer runs a thor command.
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
    #   package :spec, :thorfile => "/var/setup/Thorfile" do
    #     thor 'spec'
    #   end
     
    class Thor < Installer
      
      api do
        def thor(name, options = {}, &block)
          install Sprinkle::Installers::Thor.new(self, name, options, &block)
        end  
      end
      
      def initialize(parent, commands, options = {}, &block) #:nodoc:
        super parent, options, &block
        @commands = commands
      end

      protected

        def install_commands #:nodoc:
          file = @options[:thorfile] ? "-f #{@options[:thorfile]} " : ""
          "thor #{file}#{@commands}"
        end

    end
  end
end
