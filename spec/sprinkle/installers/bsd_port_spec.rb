require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::BsdPort do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_port(ports, &block)
    Sprinkle::Installers::BsdPort.new(@package, ports, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_port 'lang/ruby'
      @installer.port.should == 'lang/ruby'
    end

  end

  describe 'during installation' do

    before do
      @installer = create_port 'lang/ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the port installer for all specified packages' do
      @install_commands.should =~ /cd \/usr\/ports\/lang\/ruby && make BATCH=yes install clean/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', 'sh -c \'cd /usr/ports/lang/ruby && make BATCH=yes install clean\'', 'op2' ]
    end

  end

end
