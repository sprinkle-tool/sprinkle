require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Apt do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_apt(debs, &block)
    Sprinkle::Installers::Apt.new(@package, debs, &block)
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

  describe 'during installation' do

    before do
      @installer = create_apt 'ruby'
      @install_sequence = @installer.send :install_sequence
    end

    it 'should invoke the apt installer for all specified packages' do
      @install_sequence.should =~ /apt-get -qyu install ruby/
    end

    it 'should specify a non interactive mode to the apt installer' do
      @install_sequence.should =~ /DEBIAN_FRONTEND=noninteractive/
    end

    it 'should install a specific version if defined'

  end

end
