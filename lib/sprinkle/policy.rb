require 'highline/import'

module Sprinkle
  # = Policies
  #
  # A policy defines a set of packages which are required for a certain
  # role (app, database, etc.). All policies defined will be run and all
  # packages required by the policy will be installed. So whereas defining
  # a Sprinkle::Package merely defines it, defining a Sprinkle::Policy 
  # actually causes those packages to install. 
  #
  # == A Basic Example
  #
  #   policy :blog, :roles => :app do
  #     require :webserver
  #     require :database
  #     require :rails
  #   end
  #
  # This says that for the blog on the app role, it requires certain 
  # packages. The :roles option is <em>exactly</em> the same as a capistrano
  # or vlad role. A role merely defines what server the commands are run
  # on. This way, a single Sprinkle script can provision an entire group
  # of servers. 
  #
  # To define a role, put in your actor specific configuration file (recipe or
  # script file):
  #
  #   role :app, "208.28.38.44"
  #
  # The capistrano and vlad syntax is the same for that. If you're using a
  # custom actor, you may have to do it differently.
  #
  # == Multiple Policies
  #
  # You may specify as many policies as you'd like. If the packages you're
  # requiring are properly defined with verification blocks, then
  # no software will be installed twice, so you may require a webserver on
  # multiple packages within the same role without having to wait for
  # that package to install repeatedly.
  module Policy
    POLICIES = [] #:nodoc:

    # Defines a single policy. Currently the only option, which is also
    # required, is :roles, which defines which servers a policy is
    # used on.
    def policy(name, options = {}, &block)
      p = Policy.new(name, options, &block)
      POLICIES << p
      p
    end

    class Policy #:nodoc:
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

        cloud_info "--> Cloud hierarchy for policy #{@name}"

        @packages.each do |p|
          cloud_info "\nPolicy #{@name} requires package #{p}"

          package = Sprinkle::Package::PACKAGES[p]
          raise "Package definition not found for key: #{p}" unless package
          package = select_package(p, package) if package.is_a? Array # handle virtual package selection

          tree = package.tree do |parent, child, depth|
            indent = "\t" * depth; cloud_info "#{indent}Package #{parent.name} requires #{child.name}"
          end

          all << tree
        end

        normalize(all) do |package|
          package.process(deployment, @roles)
        end
      end

      private

        def cloud_info(message)
          logger.info(message) if Sprinkle::OPTIONS[:cloud] or logger.debug?
        end

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

          cloud_info "Selecting #{package.to_s} for virtual package #{name}"

          package
        end

        def normalize(all, &block)
          all = all.flatten.uniq
          cloud_info "\n--> Normalized installation order for all packages: #{all.collect(&:name).join(', ')}"
          all.each &block
        end
    end
  end
end
