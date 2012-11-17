require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Pear do

  before do
    @package = mock(Sprinkle::Package, :name => 'spec')
    @installer = Sprinkle::Installers::Pear.new(@package, 'spec')
  end

  describe 'during installation' do
    it 'should invoke the pear executer for all specified tasks' do
      @install_commands = @installer.send :install_commands
      @install_commands.should == "pear install --alldeps spec"
    end
  end
end
