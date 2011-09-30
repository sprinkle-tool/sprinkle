require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Binary do
  include Sprinkle::Deployment

  def create_context
    binary = 'http://www.example.com/archive.tar.gz'

    deployment = deployment do
      delivery :capistrano
      binary "http://www.example.com/archive.tar.gz" do
        prefix   '/prefix/directory'
        archives '/archives/directory'
      end
    end

    installer = create_binary binary do
      prefix   '/prefix/directory'
      archives '/archives/directory'
    end

    installer.defaults(@deployment)
    
    [binary, deployment, installer]
  end

  def create_binary(binary, version = nil, &block)
    @package = mock(Sprinkle::Package, :name => 'package', :version => version)
    Sprinkle::Installers::Binary.new(@package, binary, &block)
  end

  describe "binary#prepare_commands" do
    before do
      @binary, @deployment, @installer = create_context
    end
    
    it "should return mkdir command to create the prefix directory" do
      @installer.send(:prepare_commands)[0].should == 'mkdir -p /prefix/directory'
    end
    it "should return mkdir command to create the archives directory" do
      @installer.send(:prepare_commands)[1].should == 'mkdir -p /archives/directory'
    end
  end
  
  
  describe "binary#install_commands" do
    before do
      @binary, @deployment, @installer = create_context
    end
    
    it "should return a commands to place the binary in the correct archive directory" do
      @installer.send(:install_commands)[0].should =~ /--directory-prefix=\/archives\/directory/
    end
    
    it "should return a command to extract to the correct prefix folder" do
      @installer.send(:install_commands)[1].should =~ /cd \/prefix\/directory/
    end

    it "should return a command to extract the right file in the right directory" do
      @installer.send(:install_commands)[1].should =~ / \/archives\/directory\/archive.tar.gz/
    end
  end
  
end
