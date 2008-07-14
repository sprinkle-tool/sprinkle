require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Apt do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_apt(*debs, &block)
    Sprinkle::Installers::Apt.new(@package, *debs, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_apt 'ruby'
      @installer.packages.should == [ 'ruby' ]
    end

    it 'should accept an array of packages to install' do
      @installer = create_apt %w( gcc gdb g++ )
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end

  end

  describe 'when created for :build_dep install' do

    it 'should remove :build_dep from packages list' do
      @installer = create_apt :build_dep, 'ruby'
      @installer.packages.should == [ 'ruby' ]
    end

  end

  describe 'during installation' do

    before do
      @installer = create_apt 'ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the apt installer for all specified packages' do
      @install_commands.should =~ /apt-get -qyu install ruby/
    end

    it 'should specify a non interactive mode to the apt installer' do
      @install_commands.should =~ /DEBIAN_FRONTEND=noninteractive/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', %(DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get -qyu install ruby), 'op2' ]
    end

    it 'should install a specific version if defined'

  end
  
  describe 'during :build_dep installation' do

    before do
      @installer = create_apt :build_dep, 'ruby'
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the apt installer with build-dep command for all specified packages' do
      @install_commands.should =~ /apt-get -qyu build-dep ruby/
    end
    
  end
end
