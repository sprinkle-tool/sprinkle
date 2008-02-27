require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Installer, 'when created' do
  
  it 'should belong to a package'
  
  it 'should accept an optional block to customize installers defaults'
  
end

describe Sprinkle::Installers::Installer, 'during configuration' do
    
  it 'should accept be configurable via external defaults'
  
  it 'should select the defaults for the particular concrete installer class'
  
  it 'should configure the installer delivery mechansim'

  it 'should maintain an options hash set arbitrarily via method missing'
  
end

describe Sprinkle::Installers::Installer, 'during installation' do
  
  it 'should request the install sequence from the concrete class'
  
  it 'should invoke the delivery mechanism to process the install sequence'
  
end