require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Package do
  include Sprinkle::Package

  before do 
    @name = :package_name
    @empty = Proc.new { }
    @opts = { }
  end
  
  describe Sprinkle::Package, 'when created' do
    
    it 'should be invalid without a block descriptor' do 
      lambda { package @name }.should raise_error
    end
    
    it 'should be invalid without a name' do
      lambda { package nil, &@empty }.should raise_error
      lambda { package @name, &@empty }.should_not raise_error
    end
    
    it 'should optionally accept a description' do
      pkg = package @name do
        description 'my package description'
      end
      pkg.description.should == 'my package description'
    end
    
    it 'should optionally accept a version' do
      pkg = package @name do
        version '2.0.2'
      end
      pkg.version.should == '2.0.2'
    end
    
    it 'should optionally accept an installer' do 
      pkg = package @name do
        gem 'rails'
      end
      pkg.installer.should_not be_nil
    end
    
    it 'should optionally accept dependencies' do 
      pkg = package @name do
        requires :webserver, :database
      end
      pkg.dependencies.should == [:webserver, :database]
    end
    
    it 'should optionally define a virtual package implementation' do 
      pkg = package @name, :provides => :database do; end
      pkg.provides.should == :database
    end
    
    it 'should be able to represent itself as a string' do 
      pkg = package @name do; end
      pkg.to_s.should == @name
    end

  end

  describe Sprinkle::Package, 'helper method' do 
    
    it 'should added new packages to the global package hash' do 
      pkg = package @name do; end
      Sprinkle::Package::PACKAGES[@name].should == pkg
    end
    
    it 'should add the new package to the provides list if specified' do 
      pkg = package @name, :provides => :database do; end
      Sprinkle::Package::PACKAGES[:database].last.should == pkg
    end
    
  end

  describe Sprinkle::Package, 'installer configuration' do
    
    it 'should optionally accept an apt installer'
    it 'should optionally accept a gem installer'
    it 'should optionally accept a source installer'
    
  end

  describe Sprinkle::Package, 'with a source installer' do
    
    it 'should optionally accept a block containing customisations'
    it 'should automatically add a build essential dependency'
    
  end

  describe Sprinkle::Package, 'with an gem installer' do
    
    it 'should automatically add a rubygems dependency'
    
  end

  describe Sprinkle::Package, 'when processing' do
    
    it 'should configure itself against the deployment context'
    it 'should request the installer to process itself'
    
  end

  describe Sprinkle::Package, 'hierarchies' do
    
    it 'should be able to return a dependency hierarchy tree'
    it 'should optionally accept a block to call upon item in the tree during hierarchy traversal'
    it 'should maintain a depth count of how deep the hierarchy is'
    
  end

end
