require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Policy do
  include Sprinkle::Policy
  
  before do 
    @name = 'a policy'
  end
  
  describe Sprinkle::Policy, 'when created' do
    
    it 'should be invalid without a name' do 
      lambda { policy nil }.should raise_error
    end
    
    it 'should be invalid without role definitions' do 
      lambda { policy @name do; end }.should raise_error
      lambda { policy @name, :roles => :app do; end }.should_not raise_error
    end
    
    it 'should optionally accept package dependencies' do 
      p = policy @name, :roles => :app do; end
      p.should respond_to(:requires)
      p.requires :appserver
      p.packages.should == [ :appserver ]
    end
    
    it 'should optionally accept package dependencies with versions' do 
      p = policy @name, :roles => :app do; end
      p.requires :appserver, :version => 2
      p.packages.should == [ :appserver ]
      pending 'requires version checking implementation'
    end
    
    it 'should add itself to the global policy list' do 
      sz = Sprinkle::Policy::POLICIES.size
      p = policy @name, :roles => :app do; end
      Sprinkle::Policy::POLICIES.size.should == sz + 1
      Sprinkle::Policy::POLICIES.last.should == p
    end
    
  end

  describe Sprinkle::Policy, 'when applying' do
    
    it 'should determine the packages to install via the hierarchy dependency tree of each package in the policy'
    it 'should normalize (ie remove duplicates from) the installation order of all packages including dependencies'
    it 'should process each normalized package in reverse dependency order'
    
  end

  describe Sprinkle::Policy, 'containing package dependencies with versions' do
    
    it 'should be invalid if the specified package does not exist'
    it 'should ignore any packages of the same name that have other versions'
    it 'should select the correct package version when applying'
    
  end

  describe Sprinkle::Policy, 'containing virtual packages' do
    
    it 'should automatically select a concrete package implementation for a virtual one when there exists only one possible selection'
    it 'should ask the user for the concrete package implementation to use for a virtual one when more than one possible choice exists'
    
  end
  
end
