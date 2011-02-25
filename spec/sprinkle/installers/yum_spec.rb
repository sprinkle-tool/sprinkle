require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Yum do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
  end

  def create_rpm(rpms, &block)
    Sprinkle::Installers::Yum.new(@package, rpms, &block)
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
      @installer = create_rpm 'ruby' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the rpm installer for all specified packages' do
      @install_commands.should =~ /yum install ruby -y/
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', 'yum install ruby -y', 'op2' ]
    end

    it 'should install a specific version if defined' do
      pending
    end

  end

end
