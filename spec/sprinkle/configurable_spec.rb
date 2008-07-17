require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Configurable do
  module MyPrefix
    class Configurable
      include Sprinkle::Configurable
    end
  end
  
  before do
    @configurable = MyPrefix::Configurable.new
    @default = Proc.new { }
    @defaults = { :configurable => @default }
    @deployment.stub!(:defaults).and_return(@defaults)
    @deployment.stub!(:style)
  end

  it 'should be configurable via external defaults' do
    @configurable.should respond_to(:defaults)
  end

  it 'should select the defaults for the particular concrete installer class' do
    @deployment.should_receive(:defaults).and_return(@defaults)
    @defaults.should_receive(:[]).with(:configurable).and_return(@default)
  end

  it 'should configure the installer delivery mechansim' do
    @configurable.should_receive(:instance_eval)
  end

  it 'should maintain an options hash set arbitrarily via method missing' do
    @configurable.instance_eval do
      hsv 'gts'
    end
    @configurable.hsv.should == 'gts'
  end

  after do
    @configurable.defaults(@deployment)
  end
end