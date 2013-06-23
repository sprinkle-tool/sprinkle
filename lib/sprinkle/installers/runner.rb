module Sprinkle
  module Installers
    # The runner installer is great for running a simple command.
    #
    # == Example Usage
    #
    #   package :magic_beans do
    #     runner "make world"
    #   end
    #
    # You can also pass multiple commands as arguments or an array.
    #
    #   package :magic_beans do
    #     runner "make world", "destroy world"
    #     runner [ "make world", "destroy world" ]
    #   end
    #
    # Environment variables can be supplied throught the :env option.
    #
    #   package :magic_beans do
    #     runner "make world", :env => {
    #       :PATH => '/this/is/my/path:$PATH'
    #     }
    #   end
    #
    class Runner < Installer

      api do
        def runner(*cmds, &block)
          options = cmds.extract_options!
          install Runner.new(self, cmds, options, &block)
        end

        # runs 'echo noop' on the remote host
        def noop
          install Runner.new(self, "echo noop")
        end
      end

      attr_accessor :cmds #:nodoc:
      def initialize(parent, cmds, options = {}, &block) #:nodoc:
        super parent, options, &block
        @env = options.delete(:env)
        @cmds = [*cmds].flatten
        raise "you need to specify a command" if cmds.nil?
      end

      protected

        def env_str #:nodoc:
          @env_str ||= @env.inject("env ") do |s, (k,v)|
            s << "#{k.to_s.upcase}=#{v} "
          end
        end

        def install_commands #:nodoc:
          cmds = @env ? @cmds.map { |cmd| "#{env_str}#{cmd}"} : @cmds

          sudo? ?
            cmds.map { |cmd| "#{sudo_cmd}#{cmd}"} :
            cmds
        end
    end
  end
end
