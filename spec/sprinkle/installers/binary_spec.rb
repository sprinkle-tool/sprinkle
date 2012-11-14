require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Binary do
  include Sprinkle::Deployment

  def create_context(source = 'http://www.example.com/archive.tar.gz')
    deployment = deployment do
      delivery :capistrano
      binary source do
        prefix   '/prefix/directory'
        archives '/archives/directory'
      end
    end

    installer = create_binary source do
      prefix   '/prefix/directory'
      archives '/archives/directory'
    end

    installer.defaults(@deployment)

    [source, deployment, installer]
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
      @installer.send(:install_commands)[1].should =~ / '\/archives\/directory\/archive.tar.gz'/
    end
  end

  describe "when source contains spaces (%20's) in path" do
    before do
      _, _, @installer = create_context('http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2')
    end

    it "should correctly interpret the archive filename as it gets extracted downloaded to file system" do
      @installer.send(:install_commands)[1].should =~ / '\/archives\/directory\/Sublime Text 2.0.1 x64.tar.bz2'/
    end
  end

end
