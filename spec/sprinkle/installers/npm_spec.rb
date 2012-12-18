require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Npm do

  before do
    @package = mock(Sprinkle::Package, :name => 'spec')
    @installer = Sprinkle::Installers::Npm.new(@package, 'spec')
  end

  describe 'during installation' do
    it 'should invoke the npm executer for all specified tasks' do
      @install_commands = @installer.send :install_commands
      @install_commands.should == "npm  install --global spec"
    end
  end
end
