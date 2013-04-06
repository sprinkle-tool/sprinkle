#--
# The only point of this file is to give RDoc a definition for
# Sprinkle::Actors. This file in production is never actually included
# since ActiveSupport only on-demand loads classes which are needed
# and this module is never explicitly needed.
#++

module Sprinkle
  # An actor is a method of command delivery to a remote machine. Actors are the
  # layer setting between Sprinkle and the systems you and wanting to apply
  # policies to.  
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
  # * transfer (source, destination, roles, options)
  #
  # Hopefully these methods are kind of fairly obvious.  They should return true
  # to indicate success and false to indicate failure.
  # The actual commands you need to execute can be retrived from 
  # +installer.install_sequence+ and +verifier.commands+.  
  
  module Actors
  end
end