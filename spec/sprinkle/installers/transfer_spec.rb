require File.expand_path("../../spec_helper", File.dirname(__FILE__))
require 'tempfile'

describe Sprinkle::Installers::Transfer do
  include Sprinkle::Deployment

  before do
    @package = double(Sprinkle::Package, :name => 'package', :sudo? => false)
    @empty = Proc.new { }
    @delivery = double(Sprinkle::Deployment, :install => true)
    @source = 'source'
    @destination = 'destination'
    @installer = create_transfer(@source, @destination)
    @roles = []
    @deployment = deployment do
      delivery :capistrano
      source do; prefix '/usr/bin'; end
    end
  end

  def create_transfer(source, dest, options={}, &block)
    i = Sprinkle::Installers::Transfer.new(@package, source, dest, options, &block)
    i.delivery = @delivery
    i
  end

  describe 'when created' do
    it 'should accept a source and destination to install' do
      @installer.source.should eq @source
      @installer.destination.should eq @destination
    end
  end

  describe 'during installation' do

    context "setting mode and owner" do
      before do 
        @installer = create_transfer @source, @destination do
          mode "744"
          owner "root"
        end
        @installer_commands = @installer.install_sequence
      end
      
      it "should include command to set owner" do
        @installer_commands.should include("chmod 744 #{@destination}")
      end
      
      it "should include command to set mode" do
        @installer_commands.should include("chown root #{@destination}")
      end
      
    end

    context 'single pre/post commands' do
      before do
        @installer = create_transfer @source, @destination do
          pre :install, 'op1'
          post :install, 'op2'
        end
        @installer_commands = @installer.install_sequence
        @delivery = @installer.delivery
      end

      it "should call the pre and post install commands around the file transfer" do
        @installer_commands.should eq ["op1",:TRANSFER, "op2"]
      end

      # it "should call transfer with recursive defaulted to nil" do
      #   @delivery.should_receive(:process).and_return
      #   @delivery.should_receive(:transfer).with(@package.name, @source, @destination, @roles, nil)
      # end

    end
    
    context 'pre/post with sudo' do
      before do
        @installer = create_transfer @source, @destination do
          @options[:sudo]= true
          pre :install, 'op1'
          post :install, 'op2'
        end
        @installer_commands = @installer.install_sequence
        @delivery = @installer.delivery
      end

      it "should call the pre and post install commands around the file transfer" do
        @installer_commands.should eq ["op1",:TRANSFER, 
          "sudo mv /tmp/sprinkle_destination destination", "op2"]
      end
    end

    context 'multiple pre/post commands' do
      before do
        @installer = create_transfer @source, @destination do
          pre :install, 'op1', 'op1-1'
          post :install, 'op2', 'op2-1'
        end
        @installer_commands = @installer.install_sequence
        @delivery = @installer.delivery
      end

      it "should call the pre and post install commands around the file transfer" do
        @installer_commands.should eq ["op1","op1-1",:TRANSFER, "op2","op2-1"]
      end

    end

    after do
      @installer.process @roles
    end
  end

  describe "if the :render flag is true" do
    before do
      allow(::ActiveSupport::Deprecation).to receive(:warn)
      @installer = create_transfer @source, @destination, :render => true
      @delivery = @installer.delivery
      @delivery.stub(:render_template_file)
      @tempfile = Tempfile.new("foo")
    end

    it "should render the source file as a template to a tempfile" do
      @installer.should_receive(:render_template_file).with(@source, anything, @package.name).and_return(@tempfile)
      @delivery.stub(:transfer)
    end

    it "should call transfer with recursive set to false" do
      @installer.should_receive(:render_template_file).with(@source, anything, @package.name).and_return(@tempfile)
      @installer.options[:recursive].should eq false
    end

    after do
      @installer.process @roles
    end
  end

  describe "if the :recursive flag is explicitly set to false" do
    before do
      @installer = create_transfer @source, @destination, :recursive => false
    end

    it "should call transfer with recursive set to false" do
      @installer.delivery
      @installer.options[:recursive].should eq false
    end

    after do
      @installer.process @roles
    end
  end
end
