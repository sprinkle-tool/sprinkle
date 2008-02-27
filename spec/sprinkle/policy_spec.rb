require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Policy, 'when created' do
  
  it 'should be invalid without a name'
  it 'should be invalid without role definitions'
  it 'should optionally accept package dependencies'
  it 'should optionally accept package dependencies with versions'
  it 'should add itself to the global policy list'
  
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