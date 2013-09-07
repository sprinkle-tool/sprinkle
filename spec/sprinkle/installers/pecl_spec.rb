require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Pecl do
  before do
    # @package = double(Sprinkle::Package, :name => 'spec', :class => double(Sprinkle::Package, :installer_methods => []))
    @package = Package.new("test") {}
  end

  describe 'providing just package name' do
    before do
      @installer = Sprinkle::Installers::Pecl.new(@package, 'spec')
    end

    describe 'during installation' do
      it 'should invoke the pecl installer' do
        @install_commands = @installer.send :install_commands
        @install_commands.should == "TERM= pecl install --alldeps spec"
      end
    end
  end

  describe 'providing explicit version' do
    before do
      @installer = Sprinkle::Installers::Pecl.new(@package, 'spec', :version => '1.1.1')
    end

    describe 'during installation' do
      it 'should invoke the pecl installer' do
        @install_commands = @installer.send :install_commands
        @install_commands.should == "TERM= pecl install --alldeps spec-1.1.1"
      end
    end
  end

  describe 'providing ini_file option' do
    describe 'during installation' do
      it 'should transfer file with default arguments in post install' do
        @installer = Sprinkle::Installers::Pecl.new(@package, 'spec', :ini_file => true) do
          self.stub(:file) do |path,options|
            path.should == "/etc/php5/conf.d/spec.ini"
            options[:content].should == "extension=spec.so"
            options[:sudo].should == true
            "post install file transfer"
          end
        end
        @install_sequence = @installer.install_sequence
        @install_sequence.should include("TERM= pecl install --alldeps spec")
        @install_sequence.should include("post install file transfer")
      end

      it 'should use custom path and content if provided' do
        @installer = Sprinkle::Installers::Pecl.new(@package, 'spec', :ini_file => {:path => "/custom/path", :content => "hello"}) do
          self.stub(:file) do |path,options|
            path.should == "/custom/path"
            options[:content].should == "hello"
          end
        end
      end

      it 'should use custom content if string passed' do
        @installer = Sprinkle::Installers::Pecl.new(@package, 'spec', :ini_file => "hello") do
          self.stub(:file) do |path,options|
            options[:content].should == "hello"
          end
        end
      end

      it 'should NOT use sudo if explicitly denied' do
        @installer = Sprinkle::Installers::Pecl.new(@package, 'spec', :ini_file => {:sudo => false}) do
          self.stub(:file) do |path,options|
            options[:sudo].should == false
          end
        end
      end
    end
  end

end
