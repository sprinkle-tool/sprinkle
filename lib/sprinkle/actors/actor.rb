module Sprinkle
  module Actors
    # An actor is a method of command delivery to a remote machine. Actors are the
    # layer setting between Sprinkle and the systems you and wanting to apply
    # policies to.  All actors should inherit from Sprinkle::Actors::Actor. 
    #
    # Sprinkle ships with actors for Capistrano, Vlad, localhost and pure SSH.
    # 99% of the time these should be sufficient but you can always write your 
    # own actor otherwise. 
    #
    # == Writing an actor
    #
    # Actors must provide only 3 methods:
    # 
    # * install (installer, roles, options)
    # * verify (verifier, roles, options)
    # * servers_for_role? (roles)
    #
    # Hopefully these methods are kind of fairly obvious.  They should return true
    # to indicate success and false to indicate failure.
    # The actual commands you need to execute can be retrived from 
    # +installer.install_sequence+ and +verifier.commands+.  
    class Actor
      
      # an actor must define this method so that each policy can ask the actor
      # if there are any servers with that policy's roles so the policy knows
      # whether it should execute or not
      #
      # input: a single role or array of roles
      def servers_for_role?(r)
        raise "please define servers_for_role?"
      end
      
      def install(*args)
        raise "you must define install"
      end
      
      def verify(*args)
        raise "you must define verify"
      end
      
    end
  end
end