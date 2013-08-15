require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Smart do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_smart(pkgs, &block)
    Sprinkle::Installers::Smart.new(@package, pkgs, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_smart 'ruby'
      @installer.packages.should == [ 'ruby' ]
    end

    it 'should accept an array of packages to install' do
      @installer = create_smart %w( gcc gdb g++ )
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end

    it 'should accept a list of packages to install' do
      @installer = Sprinkle::Installers::Smart.new(@package, "gcc", "gdb", "g++")
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end

  end

  describe 'during installation' do

    before do
      @installer = create_smart 'ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the rpm installer for all specified packages' do
      @install_commands.should == "smart install ruby -y 2>&1 | tee -a /var/log/smart-sprinkle"
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1',
        'smart install ruby -y 2>&1 | tee -a /var/log/smart-sprinkle', 'op2' ]
    end

  end

end
