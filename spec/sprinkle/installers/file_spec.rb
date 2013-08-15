require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::FileInstaller do
  include Sprinkle::Deployment

  before do
    @package = double(Sprinkle::Package, :name => 'package', :sudo? => false)
    @empty = Proc.new { }
    @delivery = double(Sprinkle::Deployment, :install => true)
    @source = 'source'
    @destination = 'destination'
    @contents = "hi"
    @installer = create_file_installer(@destination, :contents => @contents)
    @roles = []
    @deployment = deployment do
      delivery :capistrano
      source do; prefix '/usr/bin'; end
    end
  end

  def create_file_installer(dest, options={}, &block)
    i = Sprinkle::Installers::FileInstaller.new(@package, dest, options, &block)
    i.delivery = @delivery
    i
  end

  describe 'when created' do
    it 'should accept a source and destination to install' do
      @installer.contents.should eq @contents
      @installer.destination.should eq @destination
    end
  end

  describe 'during installation' do

    context "setting mode and owner" do
      before do
        @installer = create_file_installer @destination, :content => @contents do
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

    context "setting mode and owner with sudo" do
      before do
        @installer = create_file_installer @destination, :content => @contents do
          @options[:sudo]= true
          mode "744"
          owner "root"
        end
        @installer_commands = @installer.install_sequence
      end

      it "should run commands in correct order" do
        @installer_commands.should eq [
          :TRANSFER,
          "sudo mv /tmp/sprinkle_#{@destination} #{@destination}",
          "sudo chmod 744 #{@destination}",
          "sudo chown root #{@destination}"
        ]
      end
    end

    context "setting mode and owner with sudo as options" do
      before do
        @installer = create_file_installer @destination, :content => @contents,
          :mode => "744", :owner => "root" do
          @options[:sudo]= true
        end
        @installer_commands = @installer.install_sequence
      end

      it "should run commands in correct order" do
        @installer_commands.should eq [
          :TRANSFER,
          "sudo mv /tmp/sprinkle_#{@destination} #{@destination}",
          "sudo chown root #{@destination}",
          "sudo chmod 744 #{@destination}"
        ]
      end

    end


    context 'single pre/post commands' do
      before do
        @installer = create_file_installer @destination, :content => @contents do
          pre :install, 'op1'
          post :install, 'op2'
        end
        @installer_commands = @installer.install_sequence
        @delivery = @installer.delivery
      end

      it "should call the pre and post install commands around the file transfer" do
        @installer_commands.should eq ["op1",:TRANSFER, "op2"]
      end

    end

    context 'pre/post with sudo' do
      before do
        @installer = create_file_installer @destination, :content => @contents do
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
        @installer = create_file_installer @destination, :content => @contents do
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

end
