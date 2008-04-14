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
      attr_accessor :name, :provides, :installer, :dependencies
    
      def initialize(name, metadata = {}, &block)
        raise 'No package name supplied' unless name

        @name = name
        @provides = metadata[:provides]
        @dependencies = []
        self.instance_eval &block
      end
    
      def apt(*names)
        @installer = Sprinkle::Installers::Apt.new(self, *names)
      end
    
      def gem(name)
        @dependencies << :rubygems
        @installer = Sprinkle::Installers::Gem.new(self, name)
      end
    
      def source(source, &block)
        @dependencies << :build_essential # REVISIT: should only be for Ubuntu/Debian, need platform specific bits here
        @installer = Sprinkle::Installers::Source.new(self, source, &block)
      end
    
      def process(deployment, roles)
        return if meta_package?

        @installer.defaults(deployment)
        @installer.process(roles)
      end
    
      def requires(*packages)
        @dependencies << packages
        @dependencies.flatten!
      end
    
      def tree(depth = 1, &block)
        packages = []
      
        @dependencies.each do |dep|
          package = PACKAGES[dep]
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
