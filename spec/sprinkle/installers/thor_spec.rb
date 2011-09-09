require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Thor do

  before do
    @package = mock(Sprinkle::Package, :name => 'spec')
  end

  def create_thor(names, options = {}, &block)
    Sprinkle::Installers::Thor.new(@package, names, options, &block)
  end

  describe 'during installation' do

    it 'should invoke the thor executer for all specified tasks' do
      @installer = create_thor 'spec'
      @install_commands = @installer.send :install_commands
      @install_commands.should =~ /thor spec/
    end

    it 'should invoke the thor executer for all specified tasks' do
      @installer = create_thor 'spec', :thorfile => '/some/Thorfile'
      @install_commands = @installer.send :install_commands
      @install_commands.should == "thor -f /some/Thorfile spec"
    end

  end

end