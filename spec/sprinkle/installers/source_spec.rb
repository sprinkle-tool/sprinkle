require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Source, 'when created' do
  
  it 'should accept a source archive name to install'
  
end

describe Sprinkle::Installers::Source, 'before installation' do
  
  it 'should fail if no installation area has been specified'
  it 'should fail if no build area has been specified'
  it 'should fail if no source download area has been specified'
  
end

describe Sprinkle::Installers::Source, 'customized configuration' do
  
  it 'should override default options'
  it 'should support specification of "enable" options'
  it 'should support specification of "disable" options'
  it 'should support specification of "with" options'
  it 'should support specification of "without" options'
  it 'should support customized build area'
  it 'should support customized source area'
  it 'should support customized install area'
  
end

describe Sprinkle::Installers::Source, 'during gnu source archive style installation' do
    
  it 'should prepare the build area'
  it 'should prepare the installation area'
  it 'should prepare the source download area'
  it 'should download the source archive'
  it 'should extract the source archive'
  it 'should configure the source'
  it 'should build the source'
  it 'should install the source'
  
end

describe Sprinkle::Installers::Source, 'during customized installation' do
    
  it 'should prepare the build area'
  it 'should prepare the installation area'
  it 'should prepare the source download area'
  it 'should download the source archive'
  it 'should extract the source archive'
  it 'should not configure the source automatically'
  it 'should not build the source automatically'
  it 'should install the source using a custom installation command'
  
end

describe Sprinkle::Installers::Source, 'customized installer commands' do

  it 'should be run relative to the source build area'
  
end

describe Sprinkle::Installers::Source, 'pre stage commands' do

  it 'should run pre-prepare commands if any before build/install/source area preparation'
  it 'should run pre-download commands if any before downloading the source archive'
  it 'should run pre-extract commands if any before extracting the source archive'
  it 'should run pre-configure if any before configuring the source'
  it 'should run pre-build commands if any before building the source'
  it 'should run pre-install commands if any before installing the source'
  it 'should be run relative to the source build area'
  
end

describe Sprinkle::Installers::Source, 'pre stage commands' do

  it 'should run post-prepare commands if any after build/install/source area preparation'
  it 'should run post-download commands if any after downloading the source archive'
  it 'should run post-extract commands if any after extracting the source archive'
  it 'should run post-configure if any after configuring the source'
  it 'should run post-build commands if any after building the source'
  it 'should run post-install commands if any after installing the source'
  it 'should be run relative to the source build area'
  
end

describe Sprinkle::Installers::Source, 'install sequence' do
  
  it 'should prepare, then download, then extract, then configure, then build, then install'
  
end

describe Sprinkle::Installers::Source, 'source extraction' do
  
  it 'should support tgz archives'
  it 'should support tar.gz archives'
  it 'should support tar.bz2 archives'
  it 'should support tb2 archives'
  it 'should support zip archives'
  
end

