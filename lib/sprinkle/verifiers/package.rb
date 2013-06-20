# TODO: remove
module Sprinkle
  module Verifiers
    module Package
      Sprinkle::Verify.register(Sprinkle::Verifiers::Package)

      def has_package(*packages)
        puts "has_package and has_packages are depreciated"
        raise "please use has_yum and friends instead"
      end

      alias_method :has_packages, :has_package  
    end
  end
end