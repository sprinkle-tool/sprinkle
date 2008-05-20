require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Gem do

  before do
    @gem = 'rails'
    @version = '2.0.2'
  end

  def create_gem(gem, version = nil, &block)
    @package = mock(Sprinkle::Package, :name => gem, :version => version)
    Sprinkle::Installers::Gem.new(@package, gem, &block)
  end

  describe 'when created' do

    before do
      @installer = create_gem @gem, @version
    end

    it 'should accept a single package to install' do
      @installer.gem.should == @gem
    end

    it 'should optionally store a version of the gem to install' do
      @installer.version.should == '2.0.2'
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
