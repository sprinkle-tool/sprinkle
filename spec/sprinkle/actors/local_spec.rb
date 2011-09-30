require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Actors::Local do

  before do
    @local = Sprinkle::Actors::Local.new
  end

  describe 'when processing commands' do

    before do
      @commands = %w( op1 op2 )
      @roles    = %w( app )
      @name     = 'name'
    
      @local.stub!(:system).and_return
    end

    it 'should run the commands on the local system' do
      @local.should_receive(:system).twice.and_return
    end
    
    after do
      @local.process @name, @commands, @roles
    end

  end

end
