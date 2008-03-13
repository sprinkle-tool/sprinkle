require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Script, 'class' do
  
  it 'should define a entry point into the system' do
    Sprinkle::Script.should respond_to(:sprinkle)
  end
  
end

describe Sprinkle::Script, 'when given a script' do
  
  before do
    @script = 'script'
    
    @sprinkle = Sprinkle::Script.new
    Sprinkle::Script.stub!(:new).and_return(@sprinkle)
  end

  it 'should create a new Sprinkle instance' do
    Sprinkle::Script.should_receive(:new).and_return(@sprinkle)
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should evaulate the sprinkle script against the instance' do
    @sprinkle.should_receive(:instance_eval).and_return
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should ask the Sprinkle instance to process the data from the script' do
    @sprinkle.should_receive(:sprinkle)
    Sprinkle::Script.sprinkle @script
  end
  
end