module Sprinkle
  module Verifiers
    # = User Verifier
    # This was added so we dont have to verify a file to see if user was created
    # Defines a verify which can be used to test the existence of a user.
    module Users
      Sprinkle::Verify.register(Sprinkle::Verifiers::Users)
      
      # Tests that the user exists
      def has_user(user)
        @commands << "id #{user}"
      end
    end
  end
end