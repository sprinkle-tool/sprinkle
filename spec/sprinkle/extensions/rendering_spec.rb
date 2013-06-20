require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Package::Rendering, 'rendering' do
  
  before do
    @package = package :something do
    end
  end

  it "should be able to calculate md5s" do
    @package.md5("test").should == "098f6bcd4621d373cade4e832627b4f6"
  end
  
  it "should allow passing locals to template" do
    t=@package.template("hello <%= world %>", :world => "world")
    t.should == "hello world"
  end
  
  it "should be able to render a file from absolute path" do
    path=File.join(__FILE__, "../../templates/test.erb")
    t=@package.render("test")
    t.should == "hello " 
  end
  
  it "should be able to render a file from templates" do
    @package = package :new do
      @world = "world"
    end
    t=@package.render("test")
    t.should == "hello world" 
  end
    
end
