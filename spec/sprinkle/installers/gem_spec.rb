require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Gem do

  before do
    @gem = 'rails'
    @version = '2.0.2'
    @options = { :source => 'http://gems.github.com/', :repository => '/tmp/gems' }
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

  end

  describe 'during installation' do

    describe 'without a version' do

      before do
        @installer = create_gem @gem
      end

      it 'should invoke the gem installer for all specified package' do
        @installer.send(:install_sequence).should == "gem install #{@gem}"
      end

    end

    describe 'with a specific version' do

      before do
        @installer = create_gem @gem, @version
      end

      it 'should install a specific version if defined' do
        @installer.send(:install_sequence).should == "gem install #{@gem} --version '#{@version}'"
      end

    end

  end

end
