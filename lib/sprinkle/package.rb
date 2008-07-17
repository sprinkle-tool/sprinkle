module Sprinkle
  module Package
    PACKAGES = {}

    def package(name, metadata = {}, &block)
      package = Package.new(name, metadata, &block)
      PACKAGES[name] = package

      if package.provides
        (PACKAGES[package.provides] ||= []) << package
      end

      package
    end

    class Package
      include ArbitraryOptions
      attr_accessor :name, :provides, :installer, :dependencies, :recommends, :verifications

      def initialize(name, metadata = {}, &block)
        raise 'No package name supplied' unless name

        @name = name
        @provides = metadata[:provides]
        @dependencies = []
        @recommends = []
        @verifications = []
        self.instance_eval &block
      end

      def apt(*names, &block)
        @installer = Sprinkle::Installers::Apt.new(self, *names, &block)
      end

      def rpm(*names, &block)
        @installer = Sprinkle::Installers::Rpm.new(self, *names, &block)
      end

      def gem(name, options = {}, &block)
        @recommends << :rubygems
        @installer = Sprinkle::Installers::Gem.new(self, name, options, &block)
      end

      def source(source, options = {}, &block)
        @recommends << :build_essential # Ubuntu/Debian
        @installer = Sprinkle::Installers::Source.new(self, source, options, &block)
      end
      
      def verify(description = '', &block)
        @verifications << Sprinkle::Verify.new(self, description, &block)
      end

      def process(deployment, roles)
        return if meta_package?
        
        # Run a pre-test to see if the software is already installed. If so,
        # we can skip it, unless we have the force option turned on!
        unless @verifications.empty? || Sprinkle::OPTIONS[:force]
          begin
            process_verifications(deployment, roles)
            return
          rescue Sprinkle::VerificationFailed => e
            # Continue
          end
        end

        @installer.defaults(deployment)
        @installer.process(roles)
        
        process_verifications(deployment, roles)
      end
      
      def process_verifications(deployment, roles)
        @verifications.each do |v|
          v.defaults(deployment)
          v.process(roles)
        end
      end

      def requires(*packages)
        @dependencies << packages
        @dependencies.flatten!
      end

      def recommends(*packages)
        @recommends << packages
        @recommends.flatten!
      end

      def tree(depth = 1, &block)
        packages = []

        @recommends.each do |dep|
          package = PACKAGES[dep]
          next unless package # skip missing recommended packages as they can be optional
          block.call(self, package, depth) if block
          packages << package.tree(depth + 1, &block)
        end

        @dependencies.each do |dep|
          package = PACKAGES[dep]
          raise "Package definition not found for key: #{dep}" unless package
          block.call(self, package, depth) if block
          packages << package.tree(depth + 1, &block)
        end

        packages << self
      end

      def to_s; @name; end

      private

        def meta_package?
          @installer == nil
        end
    end
  end
end
