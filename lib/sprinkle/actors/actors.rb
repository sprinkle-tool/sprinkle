#--
# The only point of this file is to give RDoc a definition for
# Sprinkle::Actors. This file in production is never actually included
# since ActiveSupport only on-demand loads classes which are needed
# and this module is never explicitly needed.
#++

module Sprinkle
  # An actor is a method of command delivery to a remote machine. It is the
  # layer between sprinkle and the SSH connection to run commands. This gives
  # you the flexibility to define custom actors, for whatever purpose you need.
  #
  # 99% of the time, however, the two built-in actors Sprinkle::Actors::Capistrano
  # and Sprinkle::Actors::Vlad will be enough.
  module Actors
  end
end