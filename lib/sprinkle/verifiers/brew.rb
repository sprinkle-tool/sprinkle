module Sprinkle
  module Verifiers
    # = Brew package Verifier
    #
    # Contains a verifier to check the existance of a Homebrew formula.
    # 
    # == Example Usage
    #
    #   verify { has_brew 'ntp' }
    #
    module Brew
      Sprinkle::Verify.register(Sprinkle::Verifiers::Brew)

      # Checks to make sure the brew <tt>formula</tt> exists on the remote server.
      def has_brew(package)
        @commands << "brew list | grep  #{package}"
      end

    end
  end
end