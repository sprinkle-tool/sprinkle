require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Zypper do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_zypper(*packages, &block)
    Sprinkle::Installers::Zypper.new(@package, *packages, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_zypper 'ruby'
      @installer.packages.should == [ 'ruby' ]
    end

    it 'should accept an array of packages to install' do
      @installer = create_zypper %w( gcc gdb g++ )
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end

    it 'should accept an argument list of packages to install' do
      @installer = create_zypper "gcc", "gdb", "g++"
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end
  end

  describe 'during installation' do

    before do
      @installer = create_zypper 'ruby', 'rubygems' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the zypper installer for all specified packages' do
      @install_commands.should =~ /zypper -n install -l -R ruby rubygems/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', 'zypper -n install -l -R ruby rubygems', 'op2' ]
    end
  end
end
