require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Package::Rendering, 'rendering' do

  before do
    @root = File.expand_path(File.join(File.dirname(__FILE__), "../.."))
    @package = package :something do
    end
  end
  
  describe "path expansion" do
    
    it "should know / is root" do
      dirs = @package.send :search_paths, "/test/file"
      dirs.should eq ["/test"]
    end
    
    it "should not handle relative paths if template_search_path was not called" do
      expect do 
        dirs = @package.send :search_paths, "./test/file"
      end.to raise_error
    end
    
    it "./ is local to where we tell it to be" do
      @package.template_search_path "/my/super/package/"
      dirs = @package.send :search_paths, "./test/file"
      # should raise
      dirs.should include("/my/super/package")
      dirs.should include("/my/super/package/templates")
    end    
    
    it "should search pwd when amgiguous" do
      Dir.stub(:pwd).and_return("/path/is/")
      dirs = @package.send :search_paths, "test/file"
      dirs.should include("/path/is")
      dirs.should include("/path/is/templates")
    end
    
  end

  it "should be able to calculate md5s" do
    @package.md5("test").should == "098f6bcd4621d373cade4e832627b4f6"
  end

  it "should allow passing locals to template" do
    t = @package.template("hello <%= world %>", :world => "world")
    t.should == "hello world"
  end

  it "should allow access to the package context by default" do
    @package = package :new do
      @wowser = "wowser"
    end.instance
    @package.opts[:world]="world"
    t=@package.template("hello <%= opts[:world] %> <%= @wowser %>")
    t.should == "hello world wowser"
  end
        
  it "should be able to render a file from templates" do
    Dir.chdir(@root) do
      t = @package.render("test")
      t.should == "hello "
    end
  end

  it "should be able to render a file from absolute path" do
    path = File.join(@root, "templates/test.erb")
    t = @package.render(path)
    t.should == "hello "
  end
  
  it "should accept binding as second argument" do
    path = File.join(@root, "templates/locals.erb")
    t = @package.render(path, :world => "world")
    t.should == "hello world"
  end

end
