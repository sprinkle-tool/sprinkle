module Sprinkle
  module Actors
    # = Local Delivery Method
    #
    # This actor implementation performs any given commands on your local system, as
    # opposed to other implementations that generally run commands on a remote system
    # via the network.
    #
    # This is useful if you'd like to use Sprinkle to provision your local machine. 
    # To enable this actor, in your Sprinkle script specify the :local delivery mechanism. 
    #
    #   deployment do
    #     delivery :local
    #   end
    #
    # Note, your local machine will be assumed to be a member of all roles when applying policies
    #
    class Local
      
      def process(name, commands, roles, suppress_and_return_failures = false) #:nodoc:
        commands.each do |command|
          system command
          return false if $?.to_i != 0
        end
        return true
      end
      
    end
  end
end
