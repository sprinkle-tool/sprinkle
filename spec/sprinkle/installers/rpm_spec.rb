require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Rpm do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_rpm(debs, &block)
    Sprinkle::Installers::Rpm.new(@package, debs, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_rpm 'ruby'
      @installer.packages.should == [ 'ruby' ]
    end

    it 'should accept an array of packages to install' do
      @installer = create_rpm %w( gcc gdb g++ )
      @installer.packages.should == ['gcc', 'gdb', 'g++']
    end

  end

  describe 'during installation' do

    before do
      @installer = create_rpm 'ruby'
      @install_sequence = @installer.send :install_sequence
    end

    it 'should invoke the apt installer for all specified packages' do
      @install_sequence.should =~ /rpm -Uvh ruby/
    end

    it 'should specify a non interactive mode to the apt installer'
    it 'should install a specific version if defined'

  end

end
