module Sprinkle
  module Verifiers
    # = Apt package Verifier
    #
    # Contains a verifier to check the existance of an Apt package.
    # 
    # == Example Usage
    #
    #   verify { has_apt 'ntp' }
    #
    module Apt
      Sprinkle::Verify.register(Sprinkle::Verifiers::Apt)

      # Checks to make sure the apt <tt>package</tt> exists on the remote server.
      def has_apt(package)
        @commands << "dpkg --status #{package} | grep \"ok installed\""
      end

    end
  end
end