require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Installer do
  include Sprinkle::Deployment

  before do
    @package = double(Sprinkle::Package, :name => 'package')
    @empty = Proc.new { }
    @sequence = ['op1', 'op2']
    @delivery = double(Sprinkle::Deployment, :process => true, :install => true,
      :sudo_command => "sudo", :sudo? => false)
    @installer = create_installer
    @installer.delivery = @delivery
    @roles = []
    @deployment = deployment do
      delivery :capistrano
      source do; prefix '/usr/bin'; end
    end
  end

  def create_installer(&block)
    installer = Sprinkle::Installers::Installer.new @package, &block
    installer.stub(:puts).and_return

    # this is actually an abstract class so we'll insert a few fake install sequences
    class << installer
      def install_sequence
        ['op1', 'op2']
      end
    end

    installer
  end

  describe 'when created' do

    it 'should belong to a package' do
      @installer.package.should == @package
    end

    describe 'with a block to customize installer defaults' do

      it 'should accept an optional block to customize installers defaults' do
        @installer = create_installer do; prefix '/usr/local'; end
        @installer.prefix.should == '/usr/local'
      end

      it 'should override any deployment level defaults' do
        @installer = create_installer do; prefix '/usr/local'; end
        @installer.defaults(@deployment)
        @installer.prefix.should == '/usr/local'
      end
    end
  end

  describe 'during configuration' do
    it 'should be configurable' do
      @installer.should respond_to(:defaults)
    end
  end

  describe 'during installation' do

    # it 'should request the install sequence from the concrete class' do
    #   @installer.should_receive(:install_sequence).and_return(@sequence)
    # end

    describe 'when testing' do

      before do
        Sprinkle::OPTIONS[:testing] = true
        @logger = double(:debug => true, :debug? => true)
      end

      it 'should not invoke the delivery mechanism with the install sequence' do
        @delivery.should_not_receive(:process)
      end

      it 'should print the install sequence to the console' do
        @installer.should_receive(:logger).twice.and_return(@logger)
      end

    end

    describe "with sudo from package level" do
      before do
        @installer.package = double(Sprinkle::Package, :name => 'package', :sudo? => true)
      end

      it "should know it uses sudo" do
        @installer.sudo?.should == true
      end

      it "should offer up the sudo command" do
        @installer.sudo_cmd.should =~ /sudo /
      end
    end

    describe "with sudo" do
      before do
        @installer = Sprinkle::Installers::Installer.new @package, :sudo => true
        @installer.delivery = @delivery
      end

      it "should use sudo command from actor" do
        @installer.delivery = double(Sprinkle::Deployment, :process => true, :install => true,
          :sudo_command => "sudo -p blah")
        @installer.sudo_cmd.should =~ /sudo -p blah /
      end

      it "should know it uses sudo" do
        @installer.sudo?.should == true
      end

      it "should offer up the sudo command" do
        @installer.sudo_cmd.should =~ /sudo /
      end
    end

    describe 'when in production' do
      it 'should invoke the delivery mechanism to process the install sequence' do
        @delivery.should_receive(:install).with(@installer, @roles, :per_host => false)
      end
    end

    describe "with a pre command" do
      def create_installer_with_pre_command(cmd = nil, &block)
        installer = Sprinkle::Installers::Installer.new @package do
          pre :install, cmd if cmd

          def install_commands
            ["installer"]
          end
        end
        installer.instance_eval(&block) if block
        installer.stub(:puts).and_return
        installer.delivery = @delivery
        installer
      end
      before do
        @installer = create_installer_with_pre_command('run')
        @package.stub(:installers).and_return []
      end
      describe "string commands" do
        it "should insert the pre command for the specific package in the installation process" do
          @installer.send(:install_sequence).should == [ 'run', 'installer' ]
        end
      end
      describe "block with their embeded installers" do
        before(:each) do
          @package = Package.new("package") do; end
          @installer = create_installer_with_pre_command do
            pre :install do
              runner "b" do
                pre(:install) { runner "a" }
                post(:install) { runner "c" }
              end
            end
          end
        end
        it "should properly execute pre and post blocks" do
          @installer.send(:install_sequence).should == [ "a", "b", "c", 'installer' ]
        end
      end
      describe "blocks as commands" do
        before(:each) do
          @package = Package.new("package") do; end
          @installer = create_installer_with_pre_command do
            pre :install do
              %w(a b c)
            end
          end
        end
        it "should be able to store a block if it's the pre command" do
          @installer.send(:install_sequence).should == [ "a", "b", "c", 'installer' ]
        end
      end
      describe "arrays as commands" do
        before(:each) do
          @array = ["a", "b"]
          @installer = create_installer_with_pre_command(@array)
        end
        it "should be able to store an array if it's the pre command" do
          @installer.send(:install_sequence).should == [ @array, 'installer' ].flatten
        end
      end
    end

    after do
      @installer.process(@roles)
      Sprinkle::OPTIONS[:testing] = false
    end

  end

end
