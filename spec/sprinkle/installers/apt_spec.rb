require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Apt do

  before do
    @package = create_pkg "name", :use_sudo => false
  end

  def create_pkg(name="name", opts={})
    @package = Sprinkle::Package::Package.new(name) {}
    @package.use_sudo opts[:use_sudo]
    @package
  end

  def create_apt(*debs, &block)
    @package.apt(*debs, &block)
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

    it 'should remove options from packages list' do
      @installer = create_apt 'ruby', :dependencies_only => true
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

    it 'should use sudo if package specifies' do
      @package = create_pkg "name", :use_sudo => true
      @installer = create_apt 'ruby'
      @install_commands = @installer.send :install_commands
      @install_commands.should =~ /sudo env/
    end

    it 'should use sudo if installer specifies' do
      @package = create_pkg "name", :use_sudo => false
      @installer = create_apt 'ruby', :sudo => true
      @install_commands = @installer.send :install_commands
      @install_commands.should =~ /sudo env/
    end

    it 'should invoke the apt installer for all specified packages' do
      @install_commands.should =~ /apt-get --force-yes -qyu install ruby/
    end

    it 'should specify a non interactive mode to the apt installer' do
      @install_commands.should =~ /env DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', %(env DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get --force-yes -qyu install ruby), 'op2' ]
    end

    it 'should install a specific version if defined' do
      @installer = create_apt 'ruby=2'
      @installer.send(:install_sequence).should == [ %(env DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get --force-yes -qyu install ruby=2)]
    end

  end

  describe 'during dependencies only installation' do

    before do
      @installer = create_apt('ruby') { dependencies_only true }
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the apt installer with build-dep command for all specified packages' do
      @install_commands.should =~ /apt-get --force-yes -qyu build-dep ruby/
    end

  end

  describe 'during installation from a Ubuntu PPA' do

    before do
      # We use the (outdated) ppa name in launchpad help:
      # https://help.launchpad.net/Packaging/PPA/InstallingSoftware
      @installer = create_apt('gwibber') { ppa 'gwibber-daily/ppa'}
      @install_commands = @installer.send :install_commands
    end

    it 'should add the PPA repository before invoking apt-get' do
      @install_commands.should =~ /add-apt-repository ppa:/
    end
end
