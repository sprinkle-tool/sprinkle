require 'open4'

module Sprinkle
  module Actors
    # The local actor executes all commands on your local system, as opposed to other 
    # implementations that generally run commands on a remote system over the
    # network.
    #
    # This could be useful if you'd like to use Sprinkle to provision your 
    # local machine.  To enable this actor, in your Sprinkle script specify 
    # the :local delivery mechanism. 
    #
    #   deployment do
    #     delivery :local
    #   end
    #
    # Note: The local actor completely ignores roles and behaves as if your
    # local system was a member of all roles defined.
    class Local < Actor
      
      class LocalCommandError < StandardError; end
      
      def servers_for_role?
        true
      end
      
      def install(installer, roles, opts = {}) #:nodoc:
        # all local installer cares about is the commands
        @installer = installer
        process(installer.package.name, installer.install_sequence, roles)
      rescue LocalCommandError => e
        raise_error(e)
      ensure
        @installer = nil
      end
      
      def verify(verifier, roles, opts = {}) #:nodoc:
        process(verifier.package.name, verifier.commands, roles, :suppress_and_return_failures => true)
      end
      
      def process(name, commands, roles, opts = {}) #:nodoc:
        @log_recorder = Sprinkle::Utility::LogRecorder.new
        @suppress = opts[:suppress_and_return_failures]
        commands.each do |command|
          if command == :RECONNECT
            return true
          elsif command == :TRANSFER
            success = transfer(@installer.sourcepath, @installer.destination, roles,
              :recursive => @installer.options[:recursive])
            return false unless success
          else
            success = run_command command
            return false unless success
          end
        end
        return true
      end
      
    protected

      def run_command(cmd)
        res = run(cmd)
        if res != 0
          if @suppress
            return false
          else
            raise LocalCommandError
          end
        end
        true
      end

      def run(cmd)
        @log_recorder.reset cmd
        pid, stdin, out, err = Open4.popen4(cmd)
        ignored, status = Process::waitpid2 pid
        @log_recorder.log :err, err.read
        @log_recorder.log :out, out.read
        @log_recorder.code = status.to_i
      end
      
      def raise_error(e)
        raise Sprinkle::Errors::RemoteCommandFailure.new(@installer, @log_recorder.hash, e)
      end
      
      def transfer(source, destination, roles, opts ={}) #:nodoc:
			  opts.reverse_merge!(:recursive => true)
				flags = "-R " if opts[:recursive]
				
				run_command "cp #{flags}#{source} #{destination}"
			end
      
      
    end
  end
end
