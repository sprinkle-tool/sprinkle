require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Source do
  include Sprinkle::Deployment

  before do
    @source = 'ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p111.tar.gz'

    @deployment = deployment do
      delivery :capistrano
      source do
        prefix   '/usr'
        archives '/usr/archives'
        builds   '/usr/builds'
      end
    end

    @installer = create_source @source do
      prefix   '/usr/local'
      archives '/usr/local/archives'
      builds   '/usr/local/builds'

      enable %w( headers ssl deflate so )
      disable %w( cache proxy rewrite )

      with %w( debug extras )
      without %w( fancyisms )
    end

    @installer.defaults(@deployment)
  end

  def create_source(source, version = nil, &block)
    @package = mock(Sprinkle::Package, :name => 'package', :version => version)
    Sprinkle::Installers::Source.new(@package, source, &block)
  end

  describe 'when created' do

    it 'should accept a source archive name to install' do
      @installer.source.should == @source
    end

  end

  describe 'before installation' do

    before do
      @settings = { :prefix => '/usr/local', :archives => '/usr/local/tmp', :builds => '/usr/local/stage' }
    end

    it 'should fail if no installation area has been specified' do
      @settings.delete(:prefix)
    end

    it 'should fail if no build area has been specified' do
      @settings.delete(:builds)
    end

    it 'should fail if no source download area has been specified' do
      @settings.delete(:archives)
    end

    after do
      @settings.each { |k, v| @installer.send k, v }
      lambda { @installer.install_sequence }.should raise_error
    end

  end

  describe  'customized configuration' do

    it 'should support specification of "enable" options' do
      @installer.enable.should == %w( headers ssl deflate so )
    end

    it 'should support specification of "disable" options' do
      @installer.disable.should == %w( cache proxy rewrite )
    end

    it 'should support specification of "with" options' do
      @installer.with.should == %w( debug extras )
    end

    it 'should support specification of "without" options' do
      @installer.without.should == %w( fancyisms )
    end

    it 'should support customized build area' do
      @installer.prefix.should == '/usr/local'
    end

    it 'should support customized source area' do
      @installer.archives.should == '/usr/local/archives'
    end

    it 'should support customized install area' do
      @installer.builds.should == '/usr/local/builds'
    end

  end

  describe 'during gnu source archive style installation' do

    it 'should prepare the build, installation and source archives area' do
      @installer.should_receive(:prepare).and_return(
        [
         'mkdir -p /usr/local',
         'mkdir -p /usr/local/builds',
         'mkdir -p /usr/local/archives'
        ]
      )

    end

    it 'should download the source archive' do
      @installer.should_receive(:download).and_return(
        [
         "wget -cq --directory-prefix='/usr/local/archives' #{@source}"
        ]
      )
    end

    it 'should extract the source archive' do
      @installer.should_receive(:extract).and_return(
        [
         "bash -c 'cd /usr/local/builds && tar xzf /usr/local/archives/ruby-1.8.6-p111.tar.gz"
        ]
      )
    end

    it 'should configure the source'

    it 'should build the source' do
      @installer.should_receive(:build).and_return(
        [
         "bash -c 'cd /usr/local/builds && make > #{@package.name}-build.log 2>&1'"
        ]
      )
    end

    it 'should install the source' do
      @installer.should_receive(:install).and_return(
        [
         "bash -c 'cd /usr/local/builds && make install > #{@package.name}-install.log 2>&1'"
        ]
      )
    end

    after do
      @installer.send :install_sequence
    end

  end

  describe 'during customized installation' do

    it 'should prepare the build area'
    it 'should prepare the installation area'
    it 'should prepare the source download area'
    it 'should download the source archive'
    it 'should extract the source archive'
    it 'should not configure the source automatically'
    it 'should not build the source automatically'
    it 'should install the source using a custom installation command'

  end

  describe 'customized installer commands' do

    it 'should be run relative to the source build area'

  end

  describe 'pre stage commands' do

    it 'should run pre-prepare commands if any before build/install/source area preparation'
    it 'should run pre-download commands if any before downloading the source archive'
    it 'should run pre-extract commands if any before extracting the source archive'
    it 'should run pre-configure if any before configuring the source'
    it 'should run pre-build commands if any before building the source'
    it 'should run pre-install commands if any before installing the source'
    it 'should be run relative to the source build area'

  end

  describe 'pre stage commands' do

    it 'should run post-prepare commands if any after build/install/source area preparation'
    it 'should run post-download commands if any after downloading the source archive'
    it 'should run post-extract commands if any after extracting the source archive'
    it 'should run post-configure if any after configuring the source'
    it 'should run post-build commands if any after building the source'
    it 'should run post-install commands if any after installing the source'
    it 'should be run relative to the source build area'

  end

  describe 'install sequence' do

    it 'should prepare, then download, then extract, then configure, then build, then install'

  end

  describe 'source extraction' do

    it 'should support tgz archives'
    it 'should support tar.gz archives'
    it 'should support tar.bz2 archives'
    it 'should support tb2 archives'
    it 'should support zip archives'

  end

end
