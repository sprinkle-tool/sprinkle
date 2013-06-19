require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Policy do
  include Sprinkle::Policy

  before do
    @name = 'a policy'
  end
  
  describe 'with a role with no matching servers' do
    before do
      @policy = policy @name, :roles => :app do; end
    end
    
    it "should raise an error" do
      @deployment = mock(:style => Sprinkle::Actors::Dummy.new {})
      lambda { @policy.process(@deployment) }.should raise_error(Sprinkle::Policy::NoMatchingServersError)
    end
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
      # pending 'requires version checking implementation'
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
      actor = mock(:servers_for_role? => true)
      @deployment.stub!(:style).and_return(actor)
      Sprinkle::Package::PACKAGES.clear # reset full package list before each spec is run

      @a = package :a do; requires :b; requires :c; end
      @b = package :b, :provides => :xyz do; end
      @c = package :c, :provides => :abc do; end
      @d = package :d, :provides => :abc do; end
      
      @a.stub!(:instance).and_return(@a)
      @b.stub!(:instance).and_return(@b)
      @c.stub!(:instance).and_return(@c)
      @d.stub!(:instance).and_return(@d)

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
        @e.stub!(:instance).and_return(@e)

        @a.should_receive(:process).once.and_return
        @b.should_receive(:process).once.and_return
        @c.should_receive(:process).once.and_return
        @d.should_not_receive(:process)
        @e.should_receive(:process).once.and_return
      end
    end

    describe 'containing package dependencies with versions' do

      it 'should select the correct package version when applying' do
        @my3 = package :mysql do; version 3; end
        @my4 = package :mysql do; version 4; end
        @my5 = package :mysql do; version 5; end
        @e = package :e do; requires :mysql, :version => "4"; end
        @policy.requires :e
        @e.stub!(:instance).and_return @e
        @my4.stub!(:instance).and_return @my4
        @my3.should_not_receive(:process)
        @my5.should_not_receive(:process)
        @my4.should_receive(:process)
      end
    end

    describe 'containing virtual packages' do

      it 'should automatically select a concrete package implementation for a virtual one when there exists only one possible selection' do
        @policy = policy :virtual, :roles => :app do; requires :xyz; end
        @b.should_receive(:process)
      end

      it 'should ask the user for the concrete package implementation to use for a virtual one when more than one possible choice exists' do
        @policy = policy :virtual, :roles => :app do; requires :abc; end
        $terminal.should_receive(:choose).and_return(:c)
        @c.should_receive(:process)
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
    actor = mock(:servers_for_role? => true)
    @deployment.stub!(:style).and_return(actor)
    Sprinkle::Package::PACKAGES.clear # reset full package list before each spec is run

    @policy = policy :test, :roles => :app do; requires :z; end
    $terminal.stub!(:choose).and_return(:c) # stub out highline asking questions
  end

  it 'should raise an error if a package is missing' do
    lambda { @policy.process(@deployment) }.should raise_error
  end

end
