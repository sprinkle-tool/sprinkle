require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Actors::Local do

  before do
    @local = Sprinkle::Actors::Local.new
    
    @package = Package.new("super") {}
  end

  describe 'when processing commands' do

    before do
      @commands = %w( op1 op2 )
      @roles    = %w( app )
      @name     = 'name'
    end

    it 'should raise Sprinkle::Actors::Local::LocalCommandError when suppressing parameter is not set' do
      @local.should_receive(:run).and_return(1)

      lambda { @local.process @name, @commands, @roles }.should raise_error(Sprinkle::Actors::Local::LocalCommandError)
    end

    it 'should not raise Sprinkle::Actors::Local::LocalCommandError and instead return false when suppressing parameter is set' do
      @local.should_receive(:run).and_return(1)

      value = nil
      lambda { value = @local.process(@name, @commands, @roles, :suppress_and_return_failures => true) }.should_not raise_error(Sprinkle::Actors::Local::LocalCommandError)

      value.should_not be
    end

  end

  describe 'when installing' do

    before do
      @installer = Sprinkle::Installers::Runner.new(@package, "echo hi")
      @commands = %w( op1 op2 )
      @roles    = %w( app )
      @name     = 'name'

      @local.stub!(:run_command).and_return(0)
    end

    it 'should run the commands on the local system' do
      @local.should_receive(:run_command).once.and_return(0)
      @local.install @installer, @roles
    end

  end
  
  describe 'when verifying' do
    
    before do
      @verifier = Sprinkle::Verify::new(@package) {}
      @verifier.commands += ["test","test"]
      @roles    = %w( app )
      @name     = 'name'

      @local.stub!(:run_command).and_return(0)
    end

    it 'should run the commands on the local system' do
      @local.should_receive(:run_command).twice.and_return
      @local.verify @verifier, @roles
    end
    
  end

end
