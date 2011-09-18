require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Package do
  include Sprinkle::Package

  before do
    @name = :package_name
    @empty = Proc.new { }
    @opts = { }
  end

  # Kind of a messy way to do this but it works and DRYs out
  # the specs. Checks to make sure an installer is receiving
  # the block passed to it throught the package block.
  def check_block_forwarding_on(installer)
    eval(<<CODE)
    pre_count = 0
    lambda {
      pkg = package @name do
        #{installer} 'archive' do
          pre :install, 'preOp'
        end
      end

      pre_count = pkg.installers.first.instance_variable_get(:@pre)[:install].length
    }.should change { pre_count }.by(1)
CODE
  end

  # More of Mitchell's meta-programming to dry up specs.
  def create_package_with_blank_verify(n = 1)
    eval(<<CODE)
    @pkg = package @name do
      gem 'gem'
      #{"verify 'stuff happens' do; end\n" * n}
    end
CODE
  end

  describe 'when created' do

    it 'should be invalid without a block descriptor' do
      lambda { package @name }.should raise_error
    end

    it 'should be invalid without a name' do
      lambda { package nil, &@empty }.should raise_error
      lambda { package @name, &@empty }.should_not raise_error
    end

    it 'should optionally accept a description' do
      pkg = package @name do
        description 'my package description'
      end
      pkg.description.should == 'my package description'
    end

    it 'should optionally accept a version' do
      pkg = package @name do
        version '2.0.2'
      end
      pkg.version.should == '2.0.2'
    end

    it 'should optionally accept an installer' do
      pkg = package @name do
        gem 'rails'
      end
      pkg.installers.should_not be_empty
    end

    it 'should optionally accept dependencies' do
      pkg = package @name do
        requires :webserver, :database
      end
      pkg.dependencies.should == [:webserver, :database]
    end

    it 'should optionally accept recommended dependencies' do
      pkg = package @name do
        recommends :webserver, :database
      end
      pkg.recommends.should == [:webserver, :database]
    end

    it 'should optionally accept optional dependencies' do
      pkg = package @name do
        optional :webserver_configuration, :database_configuration
      end
      pkg.optional.should == [:webserver_configuration, :database_configuration]
    end

    it 'should optionally define a virtual package implementation' do
      pkg = package @name, :provides => :database do; end
      pkg.provides.should == :database
    end

    it 'should be able to represent itself as a string' do
      pkg = package @name do; end
      pkg.to_s.should == @name
    end

  end

  describe 'helper method' do

    it 'should added new packages to the global package hash' do
      pkg = package @name do; end
      Sprinkle::Package::PACKAGES[@name].should == pkg
    end

    it 'should add the new package to the provides list if specified' do
      pkg = package @name, :provides => :database do; end
      Sprinkle::Package::PACKAGES[:database].last.should == pkg
    end

  end

  describe 'installer configuration' do

    it 'should optionally accept an apt installer' do
      pkg = package @name do
        apt %w( deb1 deb2 )
      end
      pkg.should respond_to(:apt)
      pkg.installers.first.class.should == Sprinkle::Installers::Apt
    end

    it 'should optionally accept an rpm installer' do
      pkg = package @name do
        rpm %w( rpm1 rpm2 )
      end
      pkg.should respond_to(:rpm)
      pkg.installers.first.class.should == Sprinkle::Installers::Rpm
    end

    it 'should optionally accept a gem installer' do
      pkg = package @name do
        gem 'gem'
      end
      pkg.should respond_to(:gem)
      pkg.installers.first.class.should == Sprinkle::Installers::Gem
    end

    it 'should optionally accept a noop installer' do
      pkg = package @name do
        noop do
        end
      end
      pkg.should respond_to(:noop)
      pkg.installers.first.class.should == Sprinkle::Installers::Runner
      @installer = pkg.installers.first
      @install_commands = @installer.send :install_commands
      @install_commands.should == 'echo noop'
    end

    it 'should optionally accept an group installer' do
      pkg = package @name do
        add_group 'bob'
      end
      pkg.should respond_to(:add_group)
      pkg.installers.first.class.should == Sprinkle::Installers::Group
    end

    it 'should optionally accept a source installer' do
      pkg = package @name do
        source 'archive'
      end
      pkg.should respond_to(:source)
      pkg.installers.first.class.should == Sprinkle::Installers::Source
    end

    it 'should optionally accept an user installer' do
      pkg = package @name do
        add_user 'bob'
      end
      pkg.should respond_to(:add_user)
      pkg.installers.first.class.should == Sprinkle::Installers::User
    end

    it 'should allow multiple installer steps to be defined and respect order' do
      pkg = package @name do
        source 'archive'
        gem 'momoney'
      end

      pkg.installers.length.should == 2
      pkg.installers[0].class.should == Sprinkle::Installers::Source
      pkg.installers[1].class.should == Sprinkle::Installers::Gem
    end

		it 'should optionally accept a runner installer' do
			pkg = package @name do
				runner 'obscure_installer_by_custom_cmd'
			end
			pkg.should respond_to(:runner)
			pkg.installers.first.class.should == Sprinkle::Installers::Runner
		end
  end

  describe 'with a source installer' do

    it 'should optionally accept a block containing customisations' do
      pkg = package @name do
        source 'archive' do; end
      end
      pkg.should respond_to(:source)
      pkg.installers.first.class.should == Sprinkle::Installers::Source
    end

    it 'should forward block to installer superclass' do
      check_block_forwarding_on(:source)
    end

    it 'should automatically add a build essential recommendation' do
      pkg = package @name do
        source 'archive'
      end
      pkg.recommends.should include(:build_essential)
    end

  end

  describe 'with an apt installer' do
    it 'should forward block to installer superclass' do
      check_block_forwarding_on(:apt)
    end
  end

  describe 'with an rpm installer' do
    it 'should forward block to installer superclass' do
      check_block_forwarding_on(:rpm)
    end
  end

  describe 'with an gem installer' do

    it 'should automatically add a rubygems recommendation' do
      pkg = package @name do
        gem 'gem'
      end
      pkg.recommends.should include(:rubygems)
    end

    it 'should forward block to installer superclass' do
      check_block_forwarding_on(:gem)
    end

  end

  describe 'when processing' do

    before do
      @deployment = mock(Sprinkle::Deployment)
      @roles = [ :app, :db ]
      @installer = mock(Sprinkle::Installers::Installer, :defaults => true, :process => true)
      @package = package @name do; end
    end

    describe 'with an installer' do

      before do
        @package.installers = [ @installer ]
      end

      it 'should configure itself against the deployment context' do
        @installer.should_receive(:defaults).with(@deployment).and_return
      end

      it 'should request the installer to process itself' do
        @installer.should_receive(:process).with(@roles).and_return
      end

      after do
        @package.process(@deployment, @roles)
      end
    end

    describe 'without an installer' do

      it 'should not request the installer to process if the package is a metapackage' do
        @installer.should_not_receive(:process)
        @package.process(@deployment, @roles)
      end

    end

    describe 'with verifications' do
      before do
        @pkg = create_package_with_blank_verify(3)
        @pkg.installers = [ @installer ]
        @installer.stub!(:defaults)
        @installer.stub!(:process)
      end

      describe 'with forcing' do
        before do
          # Being explicit
          Sprinkle::OPTIONS[:force] = true
        end

        it 'should process verifications only once' do
          @pkg.should_receive(:process_verifications).once
          @pkg.process(@deployment, @roles)
        end

        after do
          # Being explicit
          Sprinkle::OPTIONS[:force] = false
        end
      end

      describe 'without forcing' do
        before do
          # Being explicit
          Sprinkle::OPTIONS[:force] = false
        end

        it 'should process verifications twice' do
          @pkg.should_receive(:process_verifications).once.with(@deployment, @roles, true).and_raise(Sprinkle::VerificationFailed.new(@pkg, ''))
          @pkg.should_receive(:process_verifications).once.with(@deployment, @roles).and_raise(Sprinkle::VerificationFailed.new(@pkg, ''))
        end

        it 'should continue with installation if pre-verification fails' do
          @pkg.should_receive(:process_verifications).twice.and_raise(Sprinkle::VerificationFailed.new(@pkg, ''))
          @installer.should_receive(:defaults)
          @installer.should_receive(:process)
        end

        it 'should only process verifications once and should not process installer if verifications succeed' do
          @pkg.should_receive(:process_verifications).once.and_return(nil)
          @installer.should_not_receive(:defaults)
          @installer.should_not_receive(:process)
        end

        after do
          begin
            @pkg.process(@deployment, @roles)
          rescue Sprinkle::VerificationFailed => e; end
        end
      end
    end

  end

  describe 'when processing verifications' do
    before do
      @deployment = mock(Sprinkle::Deployment)
      @roles = [ :app, :db ]
      @installer = mock(Sprinkle::Installers::Installer, :defaults => true, :process => true)
      @pkg = create_package_with_blank_verify(3)
      @pkg.installers = [ @installer ]
      @installer.stub!(:defaults)
      @installer.stub!(:process)
      @logger = mock(ActiveSupport::BufferedLogger, :debug => true, :debug? => true)
      @logger.stub!(:info)
    end

    it 'should request _each_ verification to configure itself against the deployment context' do
      @pkg.verifications.each do |v|
        v.should_receive(:defaults).with(@deployment).once
        v.stub!(:process)
      end
    end

    it 'should request _each_ verification to process' do
      @pkg.verifications.each do |v|
        v.stub!(:defaults)
        v.should_receive(:process).with(@roles).once
      end
    end

    it 'should enter a log info event to notify user whats happening' do
      @pkg.verifications.each do |v|
        v.stub!(:defaults)
        v.stub!(:process)
      end

      @pkg.should_receive(:logger).once.and_return(@logger)
    end

    after do
      @pkg.process_verifications(@deployment, @roles)
    end
  end

  describe 'hierarchies' do

    before do
      @a = package :a do; requires :b; end
      @b = package :b do; requires :c; end
      @c = package :c do; recommends :d; end
      @d = package :d do; end
      @e = package :e do; optional :d; end
    end

    it 'should be able to return a dependency hierarchy tree' do
      @a.tree.flatten.should == [ @d, @c, @b, @a ]
      @b.tree.flatten.should == [ @d, @c, @b ]
      @c.tree.flatten.should == [ @d, @c ]
      @d.tree.flatten.should == [ @d ]
      @e.tree.flatten.should == [ @e, @d ]
    end

    describe 'with missing recommendations' do

      before do
        @d.recommends :z
      end

      it 'should ignore missing recommendations' do
        @d.tree.flatten.should == [ @d ]
      end

    end

    describe 'with missing optional packages' do

      before do
        @d.optional :z
      end

      it 'should ignore missing recommendations' do
        @d.tree.flatten.should == [ @d ]
      end

    end

    it 'should optionally accept a block to call upon item in the tree during hierarchy traversal' do
      @count = 0
      @a.tree do
        @count += 1
      end
      @count.should == 3
    end

    it 'should maintain a depth count of how deep the hierarchy is' do
      @b.should_receive(:tree).with(2).and_return([@b])
      @a.tree do; end
    end

  end

  describe 'virtual package dependencies' do
    before do
      @a = package :a do; requires :virtual ; end
      @v1 = package :v1, :provides => :virtual do; end
      @v2 = package :v2, :provides => :virtual do; end
    end

    it 'should select package for an array' do
      @a.should_receive(:select_package).with(:virtual, [@v1,@v2]).and_return(@v1)
      @a.tree do; end
    end
  end

  describe 'with missing dependencies' do

    before do
      @pkg = package @name do
        gem 'gem'
        requires :missing
      end
    end

    it 'should raise an error if a package is missing' do
      lambda { @pkg.tree }.should raise_error
    end

  end

  describe 'with verifications' do
    it 'should create a Sprinkle::Verification object for the verify block' do
      Sprinkle::Verify.should_receive(:new).once

      create_package_with_blank_verify
    end

    it 'should create multiple Sprinkle::Verification objects for multiple verify blocks' do
      Sprinkle::Verify.should_receive(:new).twice

      create_package_with_blank_verify(2)
    end

    it 'should add each Sprinkle::Verificaton object to the @verifications array' do
      @pkg = create_package_with_blank_verify(3)
      @pkg.verifications.length.should eql(3)
    end

    it 'should initialize Sprinkle::Verification with the package name, description, and block' do
      Sprinkle::Verify.should_receive(:new) do |pkg, desc|
        pkg.name.should eql(@name)
        desc.should eql('stuff happens')
      end

      # We do a should_not raise_error because if a block was NOT passed, an error
      # is raised. This is specced in verification_spec.rb
      lambda { create_package_with_blank_verify }.should_not raise_error
    end
  end

end
