require 'highline/import'

module Sprinkle
  class NoMatchingServersError < StandardError #:nodoc:
    def initialize(name, roles)
      @name = name
      @roles = roles
    end
    
    def to_s
      "Policy #{@name} is to be installed on #{@roles.inspect} but no server has such a role."
    end
  end

  # = Policies
  #
  # Policies define a set of packages which are required for a certain
  # role (app, database, etc.). All policies defined will be run and all
  # packages required by the policy will be installed. So whereas defining
  # a Sprinkle::Package merely defines it, defining a Sprinkle::Policy 
  # actually causes those packages to install. 
  #
  # == Example
  #
  #   policy :blog, :roles => :app do
  #     requires :webserver
  #     requires :database
  #     requires :rails
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
  class Policy
    attr_reader :name 
    # roles for which a policy should be installed [required]
    attr_reader :roles 

    # creates a new policy, 
    # although policies are typically not created directly but
    # rather via the Core#policy helper.
    def initialize(name, metadata = {}, &block)
      raise 'No name provided' unless name
      raise 'No roles provided' unless metadata[:roles]

      @name = name
      @roles = metadata[:roles]
      @packages = []
      self.instance_eval(&block)
    end

    # tell a policy which packages are required
    def requires(package, *args)
      @packages << [package, args]
    end

    def packages #:nodoc:
      @packages.map {|x| x.first }
    end

    def to_s #:nodoc:
       name; end

    def process(deployment) #:nodoc:
      raise NoMatchingServersError.new(@name, @roles) unless deployment.style.servers_for_role?(@roles)
      
      all = []
      
      logger.info "[#{name}]"

      cloud_info "--> Cloud hierarchy for policy #{@name}"

      @packages.each do |p, args|
        cloud_info "  * requires package #{p}"

        opts = args.clone.extract_options!
        package = Sprinkle::Package::PACKAGES.find_all(p, opts)
        raise "Package definition not found for key: #{p}" unless package
        package = Sprinkle::Package::Chooser.select_package(p, package) if package.is_a? Array # handle virtual package selection
        # get an instance of the package and pass our config options
        package = package.instance(*args)

        tree = package.tree do |parent, child, depth|
          indent = "\t" * depth; cloud_info "#{indent}Package #{parent.name} requires #{child.name}"
        end

        all << tree
      end

      normalize(all).each do |package|
        package.process(deployment, @roles)
      end
    end

    private

      def normalize(all, &block)
        all = all.flatten.uniq {|x| [x.name, x.version] }
        cloud_info "--> Normalized installation order for all packages: #{all.collect(&:name).join(', ')}\n"
        all
      end

      def cloud_info(message)
        logger.info(message) if Sprinkle::OPTIONS[:cloud] or logger.debug?
      end

  end
end
