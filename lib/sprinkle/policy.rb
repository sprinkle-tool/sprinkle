require 'highline/import'

module Sprinkle
  module Policy
    POLICIES = []

    def policy(name, options = {}, &block)
      p = Policy.new(name, options, &block)
      POLICIES << p
      p
    end

    class Policy
      attr_reader :name, :packages

      def initialize(name, metadata = {}, &block)
        raise 'No name provided' unless name
        raise 'No roles provided' unless metadata[:roles]

        @name = name
        @roles = metadata[:roles]
        @packages = []
        self.instance_eval(&block)
      end

      def requires(package, options = {})
        @packages << package
      end

      def to_s; name; end

      def process(deployment)
        all = []

        logger.debug "Package hierarchy for policy #{@name}\n\n"

        @packages.each do |p|
          logger.debug "Policy #{@name} requires package #{p}"

          package = Sprinkle::Package::PACKAGES[p]
          package = select_package(p, package) if package.is_a? Array # handle virtual package selection

          tree = package.tree do |parent, child, depth|
            indent = "\t" * depth
            logger.debug "#{indent}Package #{parent.name} requires #{child.name}"
          end

          all << tree
        end

        normalize(all) do |package|
          package.process(deployment, @roles)
        end
      end

      private

        def select_package(name, packages)
          if packages.size <= 1
            package = packages.first
          else
            package = choose do |menu|
              menu.prompt = "Multiple choices exist for virtual package #{name}"
              menu.choices *packages.collect(&:to_s)
            end
            package = Sprinkle::Package::PACKAGES[package]
          end

          logger.debug "Selecting #{package.to_s} for virtual package #{name}"

          package
        end

        def normalize(all, &block)
          all = all.flatten.uniq
          logger.debug "Normalized installation order for all packages: #{all.collect(&:name).join(', ')}"
          all.each &block
        end
    end
  end
end
