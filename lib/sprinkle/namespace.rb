module Sprinkle
  module Namespace
    def namespace *args, &block
      name = args.first
      ::Sprinkle::Package::PACKAGES.in_scope name, &block
    end
  end
end
