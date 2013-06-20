module Sprinkle
  # stores the global list of policies as they are defined
  POLICIES = []
  
  module Core
    # Defines a single policy. Currently the only option, which is also
    # required, is :roles, which defines which servers a policy is
    # used on.
    def policy(name, options = {}, &block)
      p = Sprinkle::Policy.new(name, options, &block)
      POLICIES << p
      p
    end
      
  end
end