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
    
    it 'should optionally accept an apt installer' do 
      pkg = package @name do
        apt %w( deb1 deb2 )
      end
      pkg.should respond_to(:apt)
      pkg.installer.class.should == Sprinkle::Installers::Apt
    end
    
    it 'should optionally accept a gem installer' do 
      pkg = package @name do
        gem 'gem'
      end
      pkg.should respond_to(:gem)
      pkg.installer.class.should == Sprinkle::Installers::Gem
    end
    
    it 'should optionally accept a source installer' do 
      pkg = package @name do
        source 'archive'
      end
      pkg.should respond_to(:source)
      pkg.installer.class.should == Sprinkle::Installers::Source
    end
    
  end

  describe Sprinkle::Package, 'with a source installer' do
    
    it 'should optionally accept a block containing customisations' do 
      pkg = package @name do
        source 'archive' do; end
      end
      pkg.should respond_to(:source)
      pkg.installer.class.should == Sprinkle::Installers::Source
    end
    
    it 'should automatically add a build essential dependency' do 
      pkg = package @name do
        source 'archive'
      end
      pkg.dependencies.should include(:build_essential)
    end
    
  end

  describe Sprinkle::Package, 'with an gem installer' do
    
    it 'should automatically add a rubygems dependency' do 
      pkg = package @name do
        gem 'gem'
      end
      pkg.dependencies.should include(:rubygems)
    end
    
  end

  describe Sprinkle::Package, 'when processing' do
    
    before do 
      @deployment = mock(Sprinkle::Deployment)
      @roles = [ :app, :db ]
      @installer = mock(Sprinkle::Installers::Installer, :defaults => true, :process => true)
      @package = package @name do; end
    end
    
    describe Sprinkle::Package, 'with an installer' do 
      
      before do 
        @package.installer = @installer
      end

      it 'should configure itself against the deployment context' do 
        @installer.should_receive(:defaults).with(@deployment).and_return
      end
      
      it 'should request the installer to process itself' do 
        @installer.should_receive(:process).with(@roles).and_return
      end
      
      after do 
        @package.process(@deployment, @roles)
      end
    end
    
    describe Sprinkle::Package, 'without an installer' do 
      
      it 'should not request the installer to process if the package is a metapackage' do 
        @installer.should_not_receive(:process)
        @package.process(@deployment, @roles)
      end
      
    end
    
  end

  describe Sprinkle::Package, 'hierarchies' do
    
    before do 
      @a = package :a do; requires :b; end
      @b = package :b do; requires :c; end
      @c = package :c do; end
    end
    
    it 'should be able to return a dependency hierarchy tree' do 
      @a.tree.flatten.should == [ @c, @b, @a ]
      @b.tree.flatten.should == [ @c, @b ]
      @c.tree.flatten.should == [ @c ]
    end
    
    it 'should optionally accept a block to call upon item in the tree during hierarchy traversal' do 
      @count = 0
      @a.tree do
        @count += 1
      end
      @count.should == 2
    end
    
    it 'should maintain a depth count of how deep the hierarchy is' do 
      @b.should_receive(:tree).with(2).and_return([@b])
      @a.tree do; end
    end
    
  end

end
