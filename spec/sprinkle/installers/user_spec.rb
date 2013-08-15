require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::User do

  before do
    @package = double(Sprinkle::Package, :name => 'spec', :sudo? => false)
    @user = "bob"
  end

  def create_user(name, options = {}, &block)
    Sprinkle::Installers::User.new @package, name, options, &block
  end

  describe 'during installation' do

    it "should invoke add user" do
      @installer = create_user 'bob'
      @install_commands = @installer.send :install_commands
      @install_commands.should == "adduser --gecos ,,, bob"
    end

    it "should merge flags" do
      @installer = create_user 'bob', :flags => "-x"
      @install_commands = @installer.send :install_commands
      @install_commands.should == "adduser -x --gecos ,,, bob"
    end

    it "should use actual gecos options if passed" do
      @installer = create_user 'bob', :flags => "--gecos bob,,,"
      @install_commands = @installer.send :install_commands
      @install_commands.should == "adduser --gecos bob,,, bob"
    end

    it "should use sudo if sudo specified" do
      @installer = create_user 'bob', :sudo => true
      @install_commands = @installer.send :install_commands
      @install_commands.should == "sudo adduser --gecos ,,, bob"
    end

  end

end
