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

      option %w( foo bar baz )
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

    it 'should support specification of "option" options' do
      @installer.option.should == %w( foo bar baz )
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

    it 'should configure the source' do
      enable  = %w( headers ssl deflate so ).inject([]) { |m, value| m << "--enable-#{value}"; m }
      disable = %w( cache proxy rewrite ).inject([]) { |m, value| m << "--disable-#{value}"; m }

      with    = %w( debug extras ).inject([]) { |m, value| m << "--with-#{value}"; m }
      without = %w( fancyisms ).inject([]) { |m, value| m << "--without-#{value}"; m }

      options = "#{enable.join(' ')} #{disable.join(' ')} #{with.join(' ')} #{without.join(' ')}"

      @installer.should_receive(:build).and_return(
        [
         "bash -c 'cd /usr/local/builds && ./configure --prefix=/usr/local #{options} > #{@package.name}-configure.log 2>&1'"
        ]
      )
    end

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

    describe 'with a custom archive definition' do
      before do
        @installer.options[:custom_archive] = 'super-foo.tar'
      end

      it 'should install the source from the custom archive' do
        @installer.send(:extract_commands).first.should =~ /super-foo/
        @installer.send(:configure_commands).first.should =~ /super-foo/
        @installer.send(:build_commands).first.should =~ /super-foo/
        @installer.send(:install_commands).first.should =~ /super-foo/
      end

    end

    describe 'during a customized install' do

      before do
        @installer = create_source @source do
          custom_install 'ruby setup.rb'
        end

        @installer.defaults(@deployment)
      end

      it 'should store the custom install commands' do
        @installer.options[:custom_install].should == 'ruby setup.rb'
      end

      it 'should identify as having a custom install command' do
        @installer.should be_custom_install
      end

      it 'should not configure the source automatically' do
        @installer.should_receive(:configure).and_return([])
      end

      it 'should not build the source automatically' do
        @installer.should_receive(:build).and_return([])
      end

      it 'should install the source using a custom installation command' do
        @installer.send(:custom_install_commands).first.should =~ /ruby setup.rb/
      end

      it 'should be run relative to the source build area' do
        @installer.send(:custom_install_commands).first.should =~ %r{cd /usr/builds/ruby-1.8.6-p111}
      end

      describe 'with a customized directory' do

        before do
          @installer.options[:custom_dir] = 'test'
        end

        it 'should install the source from the custom dir path' do
          @installer.send(:custom_install_commands).first.should =~ /test/
        end

        it 'should store the custom build dir path' do
          @installer.options[:custom_dir].should == 'test'
        end

      end

    end

    after do
      @installer.send :install_sequence
    end

  end

  describe 'pre stage commands' do

    before do
      @commands = {
        :prepare   => %w( prepare1 prepare2 ),
        :download  => %w( down1 down2 ),
        :extract   => %w( ex1 ex2 ),
        :configure => %w( conf1 conf2 ),
        :build     => %w( build1 build2 ),
        :install   => %w( install1 install2 )
      }

      @installer = create_source @source
      @commands.each { |k, v| @installer.pre k, *v }
      @installer.defaults(@deployment)
    end

    it 'should run all pre-prepare commands' do
      @commands.each { |k, v| @installer.should_receive(:pre_commands).with(k).and_return(v) }
    end

    it 'should be run relative to the source build area' do
      @commands.each { |stage, command| @installer.send(:pre_commands, stage).first.should =~ %r{cd /usr/builds/ruby-1.8.6-p111} }
    end

    after do
      @installer.send :install_sequence
    end

  end

  describe 'post stage commands' do

    before do
      @commands = {
        :prepare   => %w( prepare1 prepare2 ),
        :download  => %w( down1 down2 ),
        :extract   => %w( ex1 ex2 ),
        :configure => %w( conf1 conf2 ),
        :build     => %w( build1 build2 ),
        :install   => %w( install1 install2 )
      }

      @installer = create_source @source
      @commands.each { |k, v| @installer.post k, *v }
      @installer.defaults(@deployment)
    end

    it 'should run all post-prepare commands' do
      @commands.each { |k, v| @installer.should_receive(:post_commands).with(k).and_return(v) }
    end

    it 'should be run relative to the source build area' do
      @commands.each { |stage, command| @installer.send(:post_commands, stage).first.should =~ %r{cd /usr/builds/ruby-1.8.6-p111} }
    end

    after do
      @installer.send :install_sequence
    end

  end

  describe 'install sequence' do

    it 'should prepare, then download, then extract, then configure, then build, then install' do
      %w( prepare download extract configure build install ).each do |stage|
        @installer.should_receive(stage).ordered.and_return([])
      end
    end

    after do
      @installer.send :install_sequence
    end

  end

  describe 'source extraction' do

    it 'should support tgz archives' do
      @installer.source = 'blah.tgz'
      @extraction = 'tar xzf'
    end

    it 'should support tar.gz archives' do
      @installer.source = 'blah.tgz'
      @extraction = 'tar xzf'
    end

    it 'should support tar.bz2 archives' do
      @installer.source = 'blah.tar.bz2'
      @extraction = 'tar xjf'
    end

    it 'should support tb2 archives' do
      @installer.source = 'blah.tb2'
      @extraction = 'tar xjf'
    end

    it 'should support zip archives' do
      @installer.source = 'blah.zip'
      @extraction = 'unzip'
    end

    after do
      @installer.send(:extract_command).should == @extraction
    end

  end
  
  describe 'base dir calculation' do
    
    %w( tar tar.gz tgz tar.bz2 tb2 zip ).each do |archive|
      
      it "should recognize #{archive} style archives" do
        @installer.source = "blah.#{archive}"
        @installer.send(:base_dir).should == 'blah'
      end
      
    end
    
    # def base_dir #:nodoc:
    #   if archive_name.split('/').last =~ /(.*)\.(tar\.gz|tgz|tar\.bz2|tar|tb2)/
    #     return $1
    #   end
    #   raise "Unknown base path for source archive: #{@source}, please update code knowledge"
    # end    
    
  end

end
