module Sprinkle
  module Installers
    # = Rake Installer
    #
    # This installer runs a rake command.
    # 
    # == Example Usage
    #
    # The following example runs the command "rake spec" on
    # the remote server.
    #
    #   package :spec do
    #     rake 'spec'
    #   end
    # 
    # Specify a Rakefile with the :rakefile option.
    #
    #   package :spec, :rakefile => "/var/setup/Rakefile" do
    #     rake 'spec'
    #   end
     
    class Rake < Installer
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
