module Sprinkle
  # class accessor on Package, or define a Packages scope?
  @@packages = {}
  
  def package(name, options = {}, &block)
    package = Package.new(name, options, &block)
    @@packages[name] = package
    
    if package.provides
      @@packages[package.provides] ||= []
      @@packages[package.provides] << package
    end
  end
  
  class Package
    attr_accessor :name, :options, :provides, :description
    
    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @provides = options[:provides]
      @dependencies = []
      self.instance_eval &block
    end
    
    def method_missing(sym, *args, &block)
      args.empty? ? @options[sym] : (@options[sym] = *args)
    end
    
    def description(text)
      @description = text
    end
    
    def apt(*names)
      @installer = Sprinkle::Installers::Apt.new(self, *names)
    end
    
    def gem(name)
      @dependencies << :rubygems # include an implicit rubygems dependency
      @installer = Sprinkle::Installers::Gem.new(self, name)
    end
    
    def source(source, &block)
      @dependencies << :build_essential # REVISIT: should only be for Ubuntu/Debian, need platform specific bits here
      @installer = Sprinkle::Installers::Source.new(self, source, &block)
    end
    
    def process(deployment, roles)
      #raise "No installer defined for package: #{@name}" unless @installer # support meta-packages
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
        package = @@packages[dep]
        block.call(self, package, depth) if block
        packages << package.tree(depth + 1, &block)
      end
      
      packages << self
    end
    
    def to_s; @name; end
  end
  
end
