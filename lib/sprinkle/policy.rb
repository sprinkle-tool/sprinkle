require 'highline/import'

module Sprinkle
  module Policy
    POLICIES = []
  
    def policy(name, options = {}, &block)
      POLICIES << Policy.new(name, options, &block)
    end
  
    class Policy
      attr_reader :name
    
      def initialize(name, options = {}, &block)
        @name = name
        @roles = options[:roles]
        @packages = []
        self.instance_eval(&block)
      end
    
      def requires(package, options = {})
        @packages << package
      end
    
      def to_s; name; end
    
      def process(deployment)
        all = []
      
        puts "Package hierarchy for policy #{@name}\n\n"
      
        @packages.each do |p|
          puts "Policy #{@name} requires package #{p}"
        
          package = PACKAGES[p]
          package = select_package(p, package) if package.is_a? Array # handle virtual package selection
        
          tree = package.tree do |parent, child, depth|
            depth.times { print "\t" }
            puts "Package #{parent.name} requires #{child.name}"
          end
        
          puts
        
          all << tree
        end
      
        all = all.flatten.uniq
      
        puts
        puts "Normalized installation order for all packages: #{all.collect(&:name).join(', ')}"

        all.each do |package|
          package.process(deployment, @roles)
        end
      end
    
      def select_package(name, packages)
        if packages.size <= 1
          package = packages.first
        else
          package = choose do |menu|
            menu.prompt = "Multiple choices exist for virtual package #{name}"
            menu.choices *packages.collect(&:to_s)
          end
          package = PACKAGES[package]
        end
      
        puts "Selecting #{package.to_s} for virtual package #{name}"
      
        package
      end
    end
  end
end