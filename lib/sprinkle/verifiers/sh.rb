module Sprinkle
  module Verifiers
    # = Test Verifier
    #
    # Checks that a specific shell command exits with zero.
    # 
    # == Example Usage
    #
    #   verify { sh '' }
    #
    module Sh
      Sprinkle::Verify.register(Sprinkle::Verifiers::Sh)

      # Checks to make sure a test runs successfully on the remote server
      def sh(args)
        @commands << "#{args}"
      end

    end
  end
end
