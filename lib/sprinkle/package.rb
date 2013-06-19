module Sprinkle
  # = Packages
  #
  # A package defines one or more things to provision onto the server.
  # There is a lot of flexibility in a way a package is defined but
  # let me give you a basic example:
  #
  #   package :ruby do
  #     description 'Ruby MRI'
  #     version '1.8.6'
  #     apt 'ruby'
  #
  #     verify { has_executable 'ruby' }
  #   end
  #
  # The above would define a package named 'ruby' and give it a description
  # and explicitly say its version. It is installed via apt and to verify
  # the installation was successful sprinkle will check for the executable
  # 'ruby' being availble. Pretty simple, right?
  #
  # <b>Note:</b> Defining a package does not INSTALL it. To install a
  # package, you must require it in a Sprinkle::Policy block. 
  #
  # == Pre-Requirements
  #
  # Most packages have some sort of pre-requisites in order to be installed.
  # Sprinkle allows you to define the requirements of the package, which
  # will be installed before the package itself. An example below:
  #
  #   package :rubygems do
  #     source 'http://rubyforge.org/rubygems.tgz'
  #     requires :ruby
  #   end
  #
  # In this case, when rubygems is being installed, Sprinkle will first
  # provision the server with Ruby to make sure the requirements are met.
  # In turn, if ruby has requirements, it installs those first, and so on.
  #
  # == Verifications
  #
  # Most of the time its important to know whether the software you're 
  # attempting to install was installed successfully or not. For this,
  # Sprinkle provides verifications. Verifications are one or more blocks
  # which define rules with which Sprinkle can check if it installed
  # the package successfully. If these verification blocks fail, then 
  # Sprinkle will gracefully stop the entire process. An example below:
  #
  #   package :rubygems do
  #     source 'http://rubyforge.org/rubygems.tgz'
  #     requires :ruby
  #
  #     verify { has_executable 'gem' }
  #   end
  #
  # In addition to verifying an installation was successfully, by default
  # Sprinkle runs these verifications <em>before</em> the installation to
  # check if the package is already installed. If the verifications pass
  # before installing the package, it skips the package. To override this
  # behavior, set the -f flag on the sprinkle script or set the
  # :force option to true in Sprinkle::OPTIONS
  #
  # For more information on verifications and to see all the available
  # verifications, see Sprinkle::Verify
  #
  # == Virtual Packages
  #
  # Sometimes, there are multiple packages available for a single task. An
  # example is a database package. It can contain mySQL, postgres, or sqlite!
  # This is where virtual packages come in handy. They are defined as follows:
  #
  #   package :sqlite3, :provides => :database do
  #     apt 'sqlite3'
  #   end
  #
  # The :provides option allows you to reference this package either by :sqlite3
  # or by :database. But whereas the package name is unique, multiple packages may
  # share the same provision. If this is the case, when running Sprinkle, the 
  # script will ask you which provision you want to install. At this time, you
  # can only install one. 
  #
  # == Meta-Packages
  #
  # A package doesn't require an installer. If you want to define a package which
  # merely encompasses other packages, that is fine too. Example:
  #
  #   package :meta do
  #     requires :magic_beans
  #     requires :magic_sauce
  #   end
  #
  #--
  # FIXME: Should probably document recommendations.
  #++
  module Package
    
    PACKAGES = PackageRepository.new

    def package(name, metadata = {}, &block)
      package = Package.new(name, metadata, &block)
      PACKAGES << package
      package
    end

    class Package #:nodoc:
      attr_accessor :name, :provides, :installers, :verifications
      attr_accessor :args, :opts
      cattr_reader :installer_methods
      @@installer_methods = []
      
      include Rendering
      
      def self.add_api(&block)
        before = self.instance_methods
        self.class_eval &block
        added = self.instance_methods - before
        @@installer_methods += added.map(&:to_sym)
      end

      def initialize(name, metadata = {}, &block)
        raise 'No package name supplied' unless name

        @name = name
        @metadata = metadata
        @provides = metadata[:provides]
        @dependencies = []
        @recommends = []
        @optional = []
        @verifications = []
        @installers = []
        @block = block
        # this should probably not be done twice
        self.instance_eval &block
      end
      
      def description(s=nil)
        s ? @description = s : @description
      end
      
      def version(s=nil)
        s ? @version = s : @version
      end
      
      def instance(*args)
        p=Package.new(name, @metadata) {}
        p.opts = args.extract_options!
        p.args = args
        p.instance_variable_set("@block", @block)
        p.instance_eval &@block
        p
      end
      
      def sudo?
        @use_sudo
      end
      
      def use_sudo(flag=true)
        @use_sudo = flag
      end
            
      def args
        @args || []
      end
      
      def opts
        @opts || {}
      end
      
      class ContextError < StandardError #:nodoc:
      end
      
      def get(x)
        raise ContextError, "Cannot call get inside a package, must be inside an Installer block"
      end
      
      # meta installer
      # TODO - fix to be atomic
      def push_file(file, options ={}, &block)
        raise "need content" unless options[:content]
        runner "#{"sudo " if sudo?}rm -f #{file}"
        push_text options[:content], file, options, &block
      end
                  
      def verify(description = '', &block)
        @verifications << Sprinkle::Verify.new(self, description, &block)
      end  
      
      def process(deployment, roles)
        logger.info "  * #{name}"
        return if meta_package?
        
        # Run a pre-test to see if the software is already installed. If so,
        # we can skip it, unless we have the force option turned on!
        unless @verifications.empty? || Sprinkle::OPTIONS[:force]
          begin
            process_verifications(deployment, roles, true)
            
            logger.info "    --> already installed for roles: #{roles}"
            return
          rescue Sprinkle::VerificationFailed => e
            # Continue
          end
        end

        @installers.each do |installer|
          installer.defaults(deployment)
          installer.process(roles)
        end
        
        process_verifications(deployment, roles)
        logger.info "    --> INSTALLED for roles: #{roles}"
      end
      
      def process_verifications(deployment, roles, pre = false)
        return if @verifications.blank?
        
        if pre
          logger.debug "--> Checking if #{self.name} is already installed for roles: #{roles}"
        else
          logger.debug "--> Verifying #{self.name} was properly installed for roles: #{roles}"
        end
        
        @verifications.each do |v|
          v.defaults(deployment)
          v.process(roles)
        end
      end
                  
      def requires(*packages)
        add_dependencies packages, :dependencies
      end

      def recommends(*packages)
        add_dependencies packages, :recommends
      end

      def optional(*packages)
        add_dependencies packages, :optional
      end
      
      def dependencies
        @dependencies.map {|a,b| a }
      end
      
      def tree(depth = 1, &block)
        packages = []
        packages << tree_for_packages(@recommends, :depth => depth, &block)
        packages << tree_for_packages(@dependencies, :depth => depth, :required => true, &block)
        packages << self
        packages << tree_for_packages(@optional, :depth => depth, &block)
        packages
      end

      def to_s
        "#{@name} #{@version}".strip
      end
        
      # allow an installer to request a private install queue from the package
      # for example to allow pre and post hooks to have their own installers that
      # do not mess with the packages installer list
      # 
      # returns: the private queue
      def with_private_install_queue()
        b = @installers
        @installers = private_queue =[]
        yield
        @installers = b
        private_queue
      end
      
    protected
      
      def install(i)
        @installers << i
        i
      end
      
    private
      
      def add_dependencies(packages, kind)
        opts = packages.extract_options!
        depends = instance_variable_get("@#{kind}")
        packages.each do |pack|
          depends << [pack, opts]
        end
        depends.map {|a,b| a }
      end
      
      def tree_for_packages(packages, opts={}, &block)
        depth = opts[:depth]
        tree = []
        packages.each do |dep, config|
          package = PACKAGES.find_all(dep, config)
          raise "Package definition not found for key: #{dep}" if package.empty? and opts[:required]
          next if package.empty? # skip missing recommended packages as they're allowed to not exist
          package = Chooser.select_package(dep, package) #if package.size>1
          package = package.instance(config)
          block.call(self, package, depth) if block
          tree << package.tree(depth + 1, &block)
        end
        tree
      end
      
        def cloud_info(message)
          logger.info(message) if Sprinkle::OPTIONS[:cloud] or logger.debug?
        end

        def meta_package?
          @installers.blank?
        end
    end
  end
end
