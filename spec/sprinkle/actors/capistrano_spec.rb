require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Actors::Capistrano, 'when created' do

  before do
    @recipes = 'deploy'
    @cap = ::Capistrano::Configuration.new
    ::Capistrano::Configuration.stub!(:new).and_return(@cap)
    @cap.stub!(:load).and_return
  end

  it 'should create a new capistrano object' do
    ::Capistrano::Configuration.should_receive(:new).and_return(@cap)
  end

  it 'should set equivalent logging on the capistrano object'

  describe 'with a block' do

    it 'should evaluate the block against the actor instance'
    it 'should load capistrano recipes file' do
      @cap.should_receive(:load).with('deploy').and_return
    end
  end

  after do
    @actor = Sprinkle::Actors::Capistrano.new do; recipes 'deploy'; end
  end
end

describe Sprinkle::Actors::Capistrano, 'processing commands' do

  it 'should dynamically create a capistrano task containing the commands'
  it 'should invoke capistrano task after creation'

end

describe Sprinkle::Actors::Capistrano, 'generated task' do

  it 'should use sudo to invoke commands when so configured'
  it 'should generate a name for the task including supplied parameters'
  it 'should be applicable for the supplied roles'

end
