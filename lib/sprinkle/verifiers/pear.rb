module Sprinkle
  module Verifiers
    # = Pear package Verifier
    #
    # Contains a verifier to check the existence of a Pear package.
    # 
    # == Example Usage
    #
    #   verify { has_pear 'PHP_Compat' }
    #
    module Pear
      Sprinkle::Verify.register(Sprinkle::Verifiers::Pear)

      # Checks to make sure the pear <tt>package</tt> exists on the remote server.
      def has_pear(package)
        @commands << "pear list | grep \"#{package}\" | grep \"stable\""
      end

    end
  end
end