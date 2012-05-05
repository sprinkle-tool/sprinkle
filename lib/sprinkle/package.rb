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
    PACKAGES = {}

    def package(name, metadata = {}, &block)
      package = Package.new(name, metadata, &block)
      PACKAGES[name] = package

      if package.provides
        (PACKAGES[package.provides] ||= []) << package
      end

      package
    end

    class Package #:nodoc:
      # include ArbitraryOptions
      attr_accessor :name, :provides, :installers, :verifications
      attr_accessor :args, :opts

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
      
      PKG_FORMATS = %w{apt brew deb rpm yum zypper freebsd_pkg openbsd_pkg opensolaris_pkg pacman}
      PKG_FORMATS.each do |format|
        eval "def #{format}(*names, &block)
          @installers << Sprinkle::Installers::#{format.classify}.new(self, *names, &block)
        end"
      end

      def noop(&block)
        install Sprinkle::Installers::Runner.new(self, "echo noop", &block)
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
      
      def dependencies
        @dependencies.map {|a,b| a }
      end
      
      def requires(*packages)
        opts = packages.extract_options!
        packages.each do |pack|
          @dependencies << [pack, opts]
        end
      end

      def recommends(*packages)
        opts = packages.extract_options!
        packages.each do |pack|
          @recommends << [pack, opts]
        end
        @recommends.map {|a,b| a }
      end

      def optional(*packages)
        opts = packages.extract_options!
        packages.each do |pack|
          @optional << [pack, opts]
        end
        @optional.map {|a,b| a }
      end

      def tree(depth = 1, &block)
        packages = []

        @recommends.each do |dep, config|
          package = PACKAGES[dep]
          next unless package # skip missing recommended packages as they're allowed to not exist
          package=package.instance(config)
          block.call(self, package, depth) if block
          packages << package.tree(depth + 1, &block)
        end

        @dependencies.each do |dep, config|
          package = PACKAGES[dep]
          package = select_package(dep, package) if package.is_a? Array
          
          raise "Package definition not found for key: #{dep}" unless package
          package = package.instance(config)
          block.call(self, package, depth) if block
          packages << package.tree(depth + 1, &block)
        end

        packages << self

        @optional.each do |dep, config|
          package = PACKAGES[dep]
          next unless package # skip missing optional packages as they're allow to not exist
          package = package.instance(config)
          block.call(self, package, depth) if block
          packages << package.tree(depth + 1, &block)
        end

        packages
      end

      def to_s; @name; end
      
      protected
      
      def install(i)
        @installers << i
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

          cloud_info "Selecting #{package.to_s} for virtual package #{name}"

          package
        end

        def meta_package?
          @installers.blank?
        end
    end
  end
end
