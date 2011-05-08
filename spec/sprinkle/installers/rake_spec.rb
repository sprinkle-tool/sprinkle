require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Rake do

  before do
    @package = mock(Sprinkle::Package, :name => 'spec')
  end

  def create_rake(names, options = {}, &block)
    Sprinkle::Installers::Rake.new(@package, names, options, &block)
  end

  describe 'during installation' do

    it 'should invoke the rake executer for all specified tasks' do
      @installer = create_rake 'spec'
      @install_commands = @installer.send :install_commands
      @install_commands.should =~ /rake spec/
    end

    it 'should invoke the rake executer for all specified tasks' do
      @installer = create_rake 'spec', :rakefile => '/some/Rakefile'
      @install_commands = @installer.send :install_commands
      @install_commands.should == "rake -f /some/Rakefile spec"
    end

  end

end
