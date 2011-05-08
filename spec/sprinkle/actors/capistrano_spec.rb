require File.expand_path("../../spec_helper", File.dirname(__FILE__))

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

    describe 'when verbose' do

      before do
        Sprinkle::OPTIONS[:verbose] = true
      end

      it 'should set verbose logging on the capistrano object' do
        @cap = create_cap
        @cap.config.logger.level.should == ::Capistrano::Logger::INFO
      end

    end

    describe 'when not verbose' do

      before do
        Sprinkle::OPTIONS[:verbose] = false
      end

      it 'should set quiet logging on the capistrano object' do
        @cap = create_cap
        @cap.config.logger.level.should == ::Capistrano::Logger::IMPORTANT
      end

    end

    describe 'with a block' do

      before do
        @actor = create_cap do
          recipes 'cool gear' # default is deploy
        end
      end

      it 'should evaluate the block against the actor instance' do
        @actor.loaded_recipes.should include('cool gear')
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

    before do
      @commands = %w( op1 op2 )
      @roles    = %w( app )
      @name     = 'name'

      @cap = create_cap do; recipes 'deploy'; end
      @cap.stub!(:run).and_return
      
      @testing_errors = false
    end

    it 'should dynamically create a capistrano task containing the commands' do
      @cap.config.should_receive(:task).and_return
    end

    it 'should invoke capistrano task after creation' do
      @cap.should_receive(:run).with(@name).and_return
    end
    
    it 'should raise capistrano errors when suppressing parameter is not set' do
      @testing_errors = true
      
      @cap.should_receive(:run).and_raise(::Capistrano::CommandError)
      lambda { @cap.process @name, @commands, @roles }.should raise_error(::Capistrano::CommandError)
    end
    
    it 'should not raise errors and instead return false when suppressing parameter is set' do
      @testing_errors = true
      
      @cap.should_receive(:run).and_raise(::Capistrano::CommandError)
      
      value = nil
      lambda { value = @cap.process(@name, @commands, @roles, true) }.should_not raise_error(::Capistrano::CommandError)
      
      value.should_not be
    end

    after do
      @cap.process @name, @commands, @roles unless @testing_errors
    end

  end

  describe 'transferring files' do

    before do
      @source = 'source'
			@dest   = 'dest'
      @roles    = %w( app )
      @name     = 'name'

      @cap = create_cap do; recipes 'deploy'; end
      @cap.stub!(:run).and_return
      
      @testing_errors = false
    end

    it 'should dynamically create a capistrano task containing calling upload' do
      @cap.config.should_receive(:task).and_return
    end

    it 'should invoke capistrano task after creation' do
      @cap.should_receive(:run).with(@name).and_return
    end
    
    it 'should raise capistrano errors when suppressing parameter is not set' do
      @testing_errors = true
      
      @cap.should_receive(:run).and_raise(::Capistrano::CommandError)
      lambda { @cap.process @name, @commands, @roles }.should raise_error(::Capistrano::CommandError)
    end
    
    it 'should not raise errors and instead return false when suppressing parameter is set' do
      @testing_errors = true
      
      @cap.should_receive(:run).and_raise(::Capistrano::CommandError)
      
      value = nil
      lambda { value = @cap.process(@name, @commands, @roles, true) }.should_not raise_error(::Capistrano::CommandError)
      
      value.should_not be
    end

    after do
      @cap.transfer @name, @source, @dest, @roles unless @testing_errors
    end
  end

  describe 'generated task' do

    before do
      @commands = %w( op1 op2 )
      @roles    = %w( app )
      @name     = 'name'

      @cap = create_cap do; recipes 'deploy'; end
      @cap.config.stub!(:fetch).and_return(:sudo)
      @cap.config.stub!(:invoke_command).and_return
    end

    it 'should use sudo to invoke commands when so configured' do
      @cap.config.should_receive(:fetch).with(:run_method, :sudo).and_return(:sudo)
    end

    it 'should run the supplied commands' do
      @cap.config.should_receive(:invoke_command).with('op1', :via => :sudo).ordered.and_return
      @cap.config.should_receive(:invoke_command).with('op2', :via => :sudo).ordered.and_return
    end

    it 'should be applicable for the supplied roles' do
      @cap.stub!(:run).and_return
      @cap.config.should_receive(:task).with(:install_name, :roles => @roles).and_return
    end

    after do
      @cap.process @name, @commands, @roles
    end

  end

  describe 'generated transfer' do
    before do
      @source   = 'source'
			@dest     = 'dest'
      @roles    = %w( app )
      @name     = 'name'

      @cap = create_cap do; recipes 'deploy'; end
      @cap.config.stub!(:upload).and_return
    end

    it 'should call upload with the source and destination via :scp' do
      @cap.config.should_receive(:upload).with(@source, @dest, :via => :scp, :recursive => true).and_return
    end

    it 'should be applicable for the supplied roles' do
      @cap.stub!(:run).and_return
      @cap.config.should_receive(:task).with(:install_name, :roles => @roles).and_return
    end

    after do
      @cap.transfer @name, @source, @dest, @roles
    end
  end

  describe 'generated transfer when recursive is false' do
    before do
      @source   = 'source'
			@dest     = 'dest'
      @roles    = %w( app )
      @name     = 'name'

      @cap = create_cap do; recipes 'deploy'; end
      @cap.config.stub!(:upload).and_return
    end

    it 'should call upload with the source and destination via :scp' do
      @cap.config.should_receive(:upload).with(@source, @dest, :via => :scp, :recursive => false).and_return
    end

    it 'should be applicable for the supplied roles' do
      @cap.stub!(:run).and_return
      @cap.config.should_receive(:task).with(:install_name, :roles => @roles).and_return
    end

    after do
      @cap.transfer @name, @source, @dest, @roles, false
    end
  end

end
