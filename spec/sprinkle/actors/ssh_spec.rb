require 'spec_helper'

describe Sprinkle::Actors::Ssh do
  describe 'process' do
    before do
      subject.stub(:gateway_defined?).and_return(false)
    end

    let(:commands) { %w[one two three] }
    let(:roles) { %w[app] }

    describe 'when use_sudo is true' do
      before do
        subject.use_sudo(true)
      end

      it 'prepends "sudo" to each command' do
        subject.should_receive(:process_direct).with(
          'test',
          ['sudo one', 'sudo two', 'sudo three'],
          roles
        )
        subject.process('test', commands, roles)
      end
    end

    describe 'when use_sudo is false' do
      before do
        subject.use_sudo(false)
      end

      it 'does not prepend "sudo" to each command' do
        subject.should_receive(:process_direct).with(
          'test',
          commands,
          roles
        )
        subject.process('test', commands, roles)
      end
    end
  end
end
