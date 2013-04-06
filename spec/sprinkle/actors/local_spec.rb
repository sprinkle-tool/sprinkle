require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Actors::Local do

  before do
    @local = Sprinkle::Actors::Local.new
    
    @package = Package.new("super") {}
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
