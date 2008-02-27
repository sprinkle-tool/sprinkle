require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Apt, 'when created' do
  
  it 'should accept a single package to install' do
    #@installer = Sprinkle::Installers::Apt.new('build-essential')
    #@installer.packages.should == ['build-essential']
  end
  
  it 'should accept an array of packages to install' do
    #@installer = Sprinkle::Installers::Apt.new %w( gcc gdb g++ )
    #@installer.packages.should == ['gcc', 'gdb', 'g++']
  end
  
end

describe Sprinkle::Installers::Apt, 'during installation' do
  
  it 'should invoke the apt installer for all specified packages'
  it 'should install a specific version if defined'
  
end