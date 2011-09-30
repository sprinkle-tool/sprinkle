require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Deployment do
  include Sprinkle::Deployment
  
  def create_deployment(&block)
    deployment do
      delivery :capistrano, &block
      
      source do
        prefix '/usr/local'
      end
    end
  end

  describe 'when created' do

    it 'should be invalid without a block descriptor' do
      lambda { deployment }.should raise_error
    end

    it 'should be invalid without a delivery method' do
      lambda { @deployment = deployment do; end }.should raise_error
    end

    it 'should optionally accept installer defaults' do 
      @deployment = create_deployment
      @deployment.should respond_to(:source)
    end
    
    it 'should provide installer defaults as a proc when requested' do 
      @deployment = create_deployment
      @deployment.defaults[:source].class.should == Proc
    end
    
  end 
  
  describe 'delivery specification' do
    
    before do
      @actor = mock(Sprinkle::Actors::Capistrano)
      Sprinkle::Actors::Capistrano.stub!(:new).and_return(@actor)
    end

    it 'should automatically instantiate the delivery type' do 
      @deployment = create_deployment
      @deployment.style.should == @actor
    end

    it 'should optionally accept a block to pass to the actor' do
      lambda { @deployment = create_deployment }.should_not raise_error
    end

    describe 'with a block' do

      it 'should pass the block to the actor for configuration' do
        @deployment = create_deployment do; recipes 'deploy'; end
      end

    end
  end
  
  describe 'when processing policies' do 
    
    before do 
      @policy = mock(Policy, :process => true)
      POLICIES = [ @policy ]
      @deployment = create_deployment
    end
    
    it 'should apply all policies, passing itself as the deployment context' do
      @policy.should_receive(:process).with(@deployment).and_return
    end
    
    after do
      @deployment.process
    end
  end

end
