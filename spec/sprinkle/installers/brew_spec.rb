require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Brew do

  before do
    @formula = mock(Sprinkle::Package, :name => 'formula')
  end

  def create_brew(*formulas, &block)
    Sprinkle::Installers::Brew.new(@formula, *formulas, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_brew 'ruby'
      @installer.formulas.should == [ 'ruby' ]
    end

    it 'should accept an array of packages to install' do
      @installer = create_brew %w( gcc gdb g++ )
      @installer.formulas.should == ['gcc', 'gdb', 'g++']
    end

    it 'should remove options from packages list' do
      @installer = create_brew 'ruby'
      @installer.formulas.should == [ 'ruby' ]
    end

  end

  describe 'during installation' do

    before do
      @installer = create_brew 'ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the apt installer for all specified packages' do
      @install_commands.should =~ /brew install ruby/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', %(brew install ruby), 'op2' ]
    end

    it 'should install a specific version if defined'

  end
  
  # describe 'during dependencies only installation' do
  # 
  #   before do
  #     @installer = create_apt('ruby') { dependencies_only true }
  #     @install_commands = @installer.send :install_commands
  #   end
  # 
  #   it 'should invoke the apt installer with build-dep command for all specified packages' do
  #     @install_commands.should =~ /apt-get --force-yes -qyu build-dep ruby/
  #   end
  #   
  # end
end