require 'spec_helper'

describe Sprinkle::Actors::SSH do
  describe 'process' do
    before do
      subject.stub(:gateway_defined?).and_return(false)
    end
    
    subject do
      Sprinkle::Actors::SSH.new do
        role :app, "booger.com"
      end
    end

    let(:commands) { %w[one two three] }
    let(:roles) { %w[app] }

    describe 'when use_sudo is true' do
      before do
        subject.use_sudo(true)
      end

      it 'prepends "sudo" to each command' do
        subject.send(:prepare_commands,commands).should == ['sudo one', 'sudo two', 'sudo three']
      end
    end

    describe 'when use_sudo is false' do
      before do
        subject.use_sudo(false)
      end

      it 'does not prepend "sudo" to each command' do
        subject.send(:prepare_commands,commands).should == commands
      end
    end
  end
end
