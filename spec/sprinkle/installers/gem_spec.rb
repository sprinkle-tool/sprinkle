require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Gem, 'installer' do
  
  it 'should accept a single package to install' do
    #@installer = Sprinkle::Installers::Gem.new('rake')
    #@installer.package.should == 'rake'
  end
  
end

describe Sprinkle::Installers::Gem, 'during installation' do
  
  it 'should invoke the gem installer for all specified package'
  it 'should install a specific version if defined'
  
end

