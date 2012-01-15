module Sprinkle
  module Verifiers
    # = Test Verifier
    #
    # Checks that a specific test runs successfully (using the unix test command)
    # 
    # == Example Usage
    #
    #   verify { test '-f /some_file' }
    #
    module Test
      Sprinkle::Verify.register(Sprinkle::Verifiers::Test)

      # Checks to make sure a test runs successfully on the remote server
      def test(args)
        @commands << "test #{args}"
      end

    end
  end
end