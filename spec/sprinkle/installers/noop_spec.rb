require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Noop do

  before do
    @package = mock(Sprinkle::Package, :name => 'spec')
  end

  def create_noop(names, options = {}, &block)
    Sprinkle::Installers::Noop.new(@package, options, &block)
  end

  describe 'during installation' do

    it 'should always be empty' do
      @installer = create_noop 'spec'
      @install_commands = @installer.send :install_commands
      @install_commands.should == 'echo noop'
    end

  end

end
