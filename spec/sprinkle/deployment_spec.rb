require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Deployment do
  include Sprinkle::Deployment

  describe 'when created' do

    it 'should be invalid without a block descriptor' do
      lambda { deployment }.should raise_error
    end

    it 'should be invalid without a delivery method' do
      lambda { @deployment = deployment do;end }.should raise_error
    end

    it 'should optionally accept installer defaults'
    it 'should provide installer defaults when requested'
    it 'should automatically start applying policies, passing itself as the deployment context'

  end

  describe 'delivery specification' do

    it 'should automatically instantiate the delivery type'

    it 'should optionally accept a block to pass to the actor' do
      lambda { @deployment = deployment do; delivery :capistrano do; end; end }.should_not raise_error
    end

    describe 'with a block' do

      it 'should pass the block to the actor for configuration' do
        @deployment = deployment do
          delivery :capistrano do; recipes 'deploy'; end
        end
      end

    end
  end

end
