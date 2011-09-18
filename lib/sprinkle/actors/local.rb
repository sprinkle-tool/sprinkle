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
    class Local
      
      def install(installer, roles, opts = {}) #:nodoc:
        # all local installer cares about is the commands
        process(installer.package.name, installer.install_sequence, roles)
      end
      
      def verify(verifier, roles, opts = {}) #:nodoc:
        process(verifier.package.name, verifier.commands, roles)
      end
      
      def transfer(name, source, destination, roles, opts ={}) #:nodoc:
			  opts.reverse_merge!(:recursive => true)
				flags = "-R " if opts[:recursive]
				
				system "cp #{flags}#{source} #{destination}"
			end
      
    protected
      
      def process(name, commands, roles, opts = {}) #:nodoc:
        commands.each do |command|
          system command
          return false if $?.to_i != 0
        end
        return true
      end
      
    end
  end
end
