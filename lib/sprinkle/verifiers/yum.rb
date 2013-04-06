module Sprinkle
  module Verifiers
    # = Yum package Verifier
    #
    # Contains a verifier to check the existence of a Yum package.
    #
    # == Example Usage
    #
    #   verify { has_yum 'git' }
    #
    module Yum
      Sprinkle::Verify.register(Sprinkle::Verifiers::Yum)

      # Checks to make sure the yum <tt>package</tt> exists on the remote server.
      def has_yum(package)
        @commands << "yum list installed #{package} | grep ^#{package}"
      end
    end
  end
end
