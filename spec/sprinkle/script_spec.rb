require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Script, 'class' do
  
  it 'should define a entry point into the system' do
    Sprinkle::Script.should respond_to(:sprinkle)
  end
  
end

describe Sprinkle::Script, 'when given a script' do
  
  before do
    @script = 'script'
    @filename = 'filename'
    
    @sprinkle = Sprinkle::Script.new
    Sprinkle::Script.stub!(:new).and_return(@sprinkle)
  end

  it 'should create a new sprinkle instance' do
    Sprinkle::Script.should_receive(:new).and_return(@sprinkle)
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should evaulate the sprinkle script against the instance' do
    @sprinkle.should_receive(:instance_eval).and_return
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should specify the filename if given for line number errors' do 
    @sprinkle.should_receive(:instance_eval).with(@script, @filename).and_return
    Sprinkle::Script.sprinkle @script, @filename
  end
  
  it 'should specify a filename of __SCRIPT__ by default if none is provided' do 
    @sprinkle.should_receive(:instance_eval).with(@script, '__SCRIPT__').and_return
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should automatically run in production mode by default' do
    @sprinkle.should_receive(:instance_eval).with(@script, '__SCRIPT__').and_return
    Sprinkle::Script.sprinkle @script
  end
  
  it 'should ask the Sprinkle instance to process the data from the script' do
    @sprinkle.should_receive(:sprinkle)
    Sprinkle::Script.sprinkle @script
  end
  
end
