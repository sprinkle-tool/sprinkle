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
      @deployment.source do; end
      @deployment.defaults.keys.should == [:source]
    end
    
    it 'should provide installer defaults as a proc when requested' do 
      @deployment = create_deployment
      @deployment.defaults[:source].class.should == Proc
    end
    
  end 
  
  describe 'delivery specification' do
    
    before do
      @actor = double(Sprinkle::Actors::Capistrano)
      Sprinkle::Actors::Capistrano.stub(:new).and_return(@actor)
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

    context 'without filter options' do
      before do
        @policy = double(Sprinkle::Policy, :process => true)
        Sprinkle::POLICIES.clear
        Sprinkle::POLICIES << @policy
        @deployment = create_deployment
      end

      it 'should apply all policies, passing itself as the deployment context' do
        @policy.should_receive(:process).with(@deployment).and_return
      end

      after do
        @deployment.process
      end
    end

    context 'with filter options' do
      before do
        Sprinkle::OPTIONS[:only_role] = nil
        Sprinkle::OPTIONS[:only_policy] = nil
        Sprinkle::POLICIES.clear

        @policy1 = policy :test1, :roles => :app1 do; end
        @policy2 = policy :test2, :roles => :app2 do; end
        @policy3 = policy :test3, :roles => [:app1, :app3] do; end

        @deployment = deployment do
           delivery :capistrano do
            role :app1
            role :app2
            role :app3
          end
        end
      end

      context 'with --only option' do
        it 'should only select policies for a given role' do
          Sprinkle::OPTIONS[:only_role] = 'app1'
          @policy1.should_receive(:process).with(@deployment)
          @policy2.should_not_receive(:process).with(@deployment)
          @policy3.should_receive(:process).with(@deployment)
        end

        it 'should not select any policies if a given role does not exists' do
          Sprinkle::OPTIONS[:only_role] = 'nonexistent_role'
          @policy1.should_not_receive(:process).with(@deployment)
          @policy2.should_not_receive(:process).with(@deployment)
          @policy3.should_not_receive(:process).with(@deployment)
        end
      end

      context 'with --policy option' do
        it 'should select a single given policy' do
          Sprinkle::OPTIONS[:only_policy] = 'test2'
          @policy1.should_not_receive(:process).with(@deployment)
          @policy2.should_receive(:process).with(@deployment)
          @policy3.should_not_receive(:process).with(@deployment)
        end

        it 'should not select any policies if a given policy does not exists' do
          Sprinkle::OPTIONS[:only_policy] = 'nonexistent_policy'
          @policy1.should_not_receive(:process).with(@deployment)
          @policy2.should_not_receive(:process).with(@deployment)
          @policy3.should_not_receive(:process).with(@deployment)
        end
      end

      context 'with both --only and --policy options' do
        it 'should select a given policy if its roles also contains a given role' do
          Sprinkle::OPTIONS[:only_role] = 'app3'
          Sprinkle::OPTIONS[:only_policy] = 'test3'
          @policy1.should_not_receive(:process).with(@deployment)
          @policy2.should_not_receive(:process).with(@deployment)
          @policy3.should_receive(:process).with(@deployment)
        end

        it 'should skip given policy if its roles does not contain a given role' do
          Sprinkle::OPTIONS[:only_role] = 'app2'
          Sprinkle::OPTIONS[:only_policy] = 'test3'
          @policy1.should_not_receive(:process).with(@deployment)
          @policy2.should_not_receive(:process).with(@deployment)
          @policy3.should_not_receive(:process).with(@deployment)
        end
      end

      after do
        @deployment.process
      end

    end
  end

end
