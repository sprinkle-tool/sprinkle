module Sprinkle
  module Verifiers
    # = Npm package Verifier
    #
    # Contains a verifier to check the existence of a npm module.
    # 
    # == Example Usage
    #
    #   verify { has_npm 'grunt' }
    #
    module Npm
      Sprinkle::Verify.register(Sprinkle::Verifiers::Npm)

      # Checks to make sure the npm <tt>module</tt> exists on the remote server.
      def has_npm(package)
        @commands << "npm -g list | grep \"#{package}\""
      end

    end
  end
end