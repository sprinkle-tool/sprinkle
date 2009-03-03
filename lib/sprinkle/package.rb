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

      def freebsd_pkg(*names, &block)
        @installer = Sprinkle::Installers::FreebsdPkg.new(self, *names, &block)
      end
      
      def openbsd_pkg(*names, &block)
        @installer = Sprinkle::Installers::OpenbsdPkg.new(self, *names, &block)
      end
      
      def opensolaris_pkg(*names, &block)
        @installer = Sprinkle::Installers::OpensolarisPkg.new(self, *names, &block)
      end
      
      def bsd_port(port, &block)
        @installer = Sprinkle::Installers::BsdPort.new(self, port, &block)
      end
      
      def mac_port(port, &block)
        @installer = Sprinkle::Installers::MacPort.new(self, port, &block)
      end

      def apt(*names, &block)
        @installer = Sprinkle::Installers::Apt.new(self, *names, &block)
      end

      def deb(*names, &block)
        @installer = Sprinkle::Installers::Deb.new(self, *names, &block)
      end

      def rpm(*names, &block)
        @installer = Sprinkle::Installers::Rpm.new(self, *names, &block)
      end

      def yum(*names, &block)
        @installer = Sprinkle::Installers::Yum.new(self, *names, &block)
      end

      def gem(name, options = {}, &block)
        @recommends << :rubygems
        @installer = Sprinkle::Installers::Gem.new(self, name, options, &block)
      end

      def source(source, options = {}, &block)
        @recommends << :build_essential # Ubuntu/Debian
        @installer = Sprinkle::Installers::Source.new(self, source, options, &block)
      end
      
      def rake(name, options = {}, &block)
        @installer = Sprinkle::Installers::Rake.new(self, name, options, &block)        
      end
      
      def push_text(text, path, options = {}, &block)
        @installer = Sprinkle::Installers::PushText.new(self, text, path, options, &block)
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
            process_verifications(deployment, roles, true)
            
            logger.info "--> #{self.name} already installed for roles: #{roles}"
            return
          rescue Sprinkle::VerificationFailed => e
            # Continue
          end
        end

        @installer.defaults(deployment)
        @installer.process(roles)
        
        process_verifications(deployment, roles)
      end
      
      def process_verifications(deployment, roles, pre = false)
        return if @verifications.blank?
        
        if pre
          logger.info "--> Checking if #{self.name} is already installed for roles: #{roles}"
        else
          logger.info "--> Verifying #{self.name} was properly installed for roles: #{roles}"
        end
        
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
