require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Gem do

  before do
    @gem = 'rails'
    @version = '2.0.2'
    @options = { :source => 'http://gems.github.com/', :repository => '/tmp/gems', :build_flags => '--build_flag=foo', :http_proxy => 'http://proxy:8080' }
  end

  def create_gem(gem, version = nil, options = {}, &block)
    @package = mock(Sprinkle::Package, :name => gem, :version => version, :source => nil, :repository => nil)
    Sprinkle::Installers::Gem.new(@package, gem, options, &block)
  end

  describe 'when created' do

    before do
      @installer = create_gem @gem, @version, @options
    end

    it 'should accept a single package to install' do
      @installer.gem.should == @gem
    end

    it 'should optionally store a version of the gem to install' do
      @installer.version.should == '2.0.2'
    end

    it 'should optionally store a source location of the gem to install' do
      @installer.source.should == 'http://gems.github.com/'
    end

    it 'should optionally store the repository location where gems are to be installed' do
      @installer.repository.should == @options[:repository]
    end
    
    it 'should optionally store the build flags' do
      @installer.build_flags.should == @options[:build_flags]
    end

    it 'should optionally store the http proxy' do
      @installer.http_proxy.should == @options[:http_proxy]
    end
    
  end

  describe 'during installation' do

    describe 'without a version' do

      before do
        @installer = create_gem @gem do
          pre :install, 'op1'
          post :install, 'op2'
        end
      end

      it 'should invoke the gem installer for the specified package' do
        @installer.send(:install_commands).should == "gem install #{@gem} --no-rdoc --no-ri"
      end

      it 'should automatically insert pre/post commands for the specified package' do
        @installer.send(:install_sequence).should == [ 'op1', "gem install #{@gem} --no-rdoc --no-ri", 'op2']
      end

    end

    describe 'with a specific version' do

      before do
        @installer = create_gem @gem, @version, :build_docs => true
      end

      it 'should install a specific version if defined, and with docs' do
        @installer.send(:install_commands).should == "gem install #{@gem} --version '#{@version}'"
      end

    end
    
    describe 'with build flags' do
      
      before do
        @installer = create_gem @gem, nil, :build_flags => '--option=foo'
      end
      
      it 'should install with defined build flags' do
        @installer.send(:install_commands).should == "gem install #{@gem} --no-rdoc --no-ri -- --option=foo"
      end
      
    end
    
    describe 'with http proxy' do
      
      before do
        @installer = create_gem @gem, nil, :http_proxy => 'http://proxy:8080'
      end
      
      it 'should install with defined build flags' do
        @installer.send(:install_commands).should == "gem install #{@gem} --no-rdoc --no-ri --http-proxy http://proxy:8080"
      end
      
    end
    
  end

end
