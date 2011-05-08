require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Policy do
  include Sprinkle::Policy

  before do
    @name = 'a policy'
  end

  describe 'when created' do

    it 'should be invalid without a name' do
      lambda { policy nil }.should raise_error
    end

    it 'should be invalid without role definitions' do
      lambda { policy @name do; end }.should raise_error
      lambda { policy @name, :roles => :app do; end }.should_not raise_error
    end

    it 'should optionally accept package dependencies' do
      p = policy @name, :roles => :app do; end
      p.should respond_to(:requires)
      p.requires :appserver
      p.packages.should == [ :appserver ]
    end

    it 'should optionally accept package dependencies with versions' do
      p = policy @name, :roles => :app do; end
      p.requires :appserver, :version => 2
      p.packages.should == [ :appserver ]
      pending 'requires version checking implementation'
    end

    it 'should add itself to the global policy list' do
      sz = Sprinkle::Policy::POLICIES.size
      p = policy @name, :roles => :app do; end
      Sprinkle::Policy::POLICIES.size.should == sz + 1
      Sprinkle::Policy::POLICIES.last.should == p
    end

  end

  describe 'with packages' do
    include Sprinkle::Package

    before do
      @deployment = mock(Sprinkle::Deployment)
      Sprinkle::Package::PACKAGES.clear # reset full package list before each spec is run

      @a = package :a do; requires :b; requires :c; end
      @b = package :b, :provides => :xyz do; end
      @c = package :c, :provides => :abc do; end
      @d = package :d, :provides => :abc do; end

      @policy = policy :test, :roles => :app do; requires :a; end
      $terminal.stub!(:choose).and_return(:c) # stub out highline asking questions
    end

    describe 'when applying' do
      include Sprinkle::Package

      it 'should determine the packages to install via the hierarchy dependency tree of each package in the policy' do
        @a.should_receive(:process).and_return
        @b.should_receive(:process).and_return
        @c.should_receive(:process).and_return
        @d.should_not_receive(:process)
      end

      it 'should normalize (ie remove duplicates from) the installation order of all packages including dependencies' do
        @e = package :e do; requires :b; end
        @policy.requires :e

        @a.should_receive(:process).once.and_return
        @b.should_receive(:process).once.and_return
        @c.should_receive(:process).once.and_return
        @d.should_not_receive(:process)
        @e.should_receive(:process).once.and_return
      end
    end

    describe 'containing package dependencies with versions' do

      it 'should be invalid if the specified package does not exist' do
        pending
      end
      it 'should ignore any packages of the same name that have other versions' do
        pending
      end
      it 'should select the correct package version when applying' do
        pending
      end

    end

    describe 'containing virtual packages' do

      it 'should automatically select a concrete package implementation for a virtual one when there exists only one possible selection' do
        @policy = policy :virtual, :roles => :app do; requires :xyz; end
        Sprinkle::Package::PACKAGES[:xyz].should == [ @b ]
      end

      it 'should ask the user for the concrete package implementation to use for a virtual one when more than one possible choice exists' do
        @policy = policy :virtual, :roles => :app do; requires :abc; end
        Sprinkle::Package::PACKAGES[:abc].should include(@c)
        Sprinkle::Package::PACKAGES[:abc].should include(@d)
        $terminal.should_receive(:choose).and_return(:c)
      end

    end

    after do
      @policy.process(@deployment)
    end
  end
end

describe Sprinkle::Policy, 'with missing packages' do

  before do
    @deployment = mock(Sprinkle::Deployment)
    Sprinkle::Package::PACKAGES.clear # reset full package list before each spec is run

    @policy = policy :test, :roles => :app do; requires :z; end
    $terminal.stub!(:choose).and_return(:c) # stub out highline asking questions
  end

  it 'should raise an error if a package is missing' do
    lambda { @policy.process(@deployment) }.should raise_error
  end

end
