require "spec_helper"

describe Sprinkle::Installers::Command do

  before do
    @package = double(Sprinkle::Package, :name => 'package', :sudo? => false)
    @options = {:sudo => true}
  end

  def command(command, options={}, &block)
    Sprinkle::Installers::Command.new(@package, command, options, &block)
  end

  describe 'when created' do
    it 'should accept a single package to install' do
      @installer = command 'echo "moo"'
      @installer.command.should == 'echo "moo"'
    end
  end

  describe 'during installation' do

    before do
      @installer = command 'echo "moo"' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the command installer for all specified packages' do
      @install_commands.should == %q[echo "moo"]
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', "echo \"moo\"", 'op2' ]
    end

    describe 'with sudo' do
      before do
        @installer = command 'echo "moo"', :sudo => true
        @install_commands = @installer.send :install_commands
      end
      it 'should invoke sudo if sudo option passed' do
        @install_commands.should == %q[sudo echo "moo"]
      end
    end
  end
end
