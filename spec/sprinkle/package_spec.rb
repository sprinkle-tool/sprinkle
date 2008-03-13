require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Package, 'during construction' do

  it 'should be invalid without a name' do
    lambda { Sprinkle::Package::Package.new nil, {} do; end }.should raise_error
  end

  it 'should be invalid without a description'
  it 'should optionally accept an installer'
  it 'should optionally accept a version'
  it 'should optionally accept dependencies'
  it 'should optionally define a virtual package implementation'
  it 'should be added to the global package hash'
  it 'should be able to represent itself as a string'

end

describe Sprinkle::Package, 'installer configuration' do
  
  it 'should optionally accept an apt installer'
  it 'should optionally accept a gem installer'
  it 'should optionally accept a source installer'
  
end

describe Sprinkle::Package, 'with a source installer' do
  
  it 'should optinally accept a block containing customisations'
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