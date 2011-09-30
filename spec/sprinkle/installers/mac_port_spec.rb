require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::MacPort do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_port(ports, &block)
    Sprinkle::Installers::MacPort.new(@package, ports, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_port 'ruby'
      @installer.port.should == 'ruby'
    end

  end

  describe 'during installation' do

    before do
      @installer = create_port 'ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the port installer for all specified packages' do
      @install_commands.should =~ /port install ruby/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', 'port install ruby', 'op2' ]
    end

  end

end
