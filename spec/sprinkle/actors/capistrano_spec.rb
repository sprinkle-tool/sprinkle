require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Actors::Capistrano do

  before do
    @recipes = 'deploy'
    @cap = ::Capistrano::Configuration.new
    ::Capistrano::Configuration.stub!(:new).and_return(@cap)
    @cap.stub!(:load).and_return
  end

  def create_cap(&block)
    Sprinkle::Actors::Capistrano.new &block
  end

  describe 'when created' do

    it 'should create a new capistrano object' do
      ::Capistrano::Configuration.should_receive(:new).and_return(@cap)
      create_cap
    end

    it 'should set logging on the capistrano object' do
      @cap = create_cap
      @cap.config.logger.level.should == ::Capistrano::Logger::TRACE
    end

    describe 'with a block' do

      it 'should evaluate the block against the actor instance'

      it 'should load capistrano recipes file' do
        @cap.should_receive(:load).with('deploy').and_return
      end

      after do
        @actor = create_cap do
          recipes 'deploy'
        end
      end

    end

    describe 'without a block' do

      it 'should automatically load the default capistrano configuration' do
        @cap.should_receive(:load).with('deploy').and_return
      end

      after do
        @actor = create_cap
      end

    end

  end

  describe 'recipes' do

    it 'should add the recipe location to an internal store' do
      @cap = create_cap do
        recipes 'deploy'
      end
      @cap.loaded_recipes.should == [ @recipes ]
    end

    it 'should load the given recipe' do
      @cap.should_receive(:load).with(@recipes).and_return
      create_cap
    end

  end

  describe 'processing commands' do

    it 'should dynamically create a capistrano task containing the commands'
    it 'should invoke capistrano task after creation'

  end

  describe 'generated task' do

    it 'should use sudo to invoke commands when so configured'
    it 'should generate a name for the task including supplied parameters'
    it 'should be applicable for the supplied roles'

  end

end
