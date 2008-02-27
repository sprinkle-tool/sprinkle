require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Actors::Capistrano, 'when created' do
  
  it 'should create a new capistrano object'
  it 'should set equivalent logging on the capistrano object'
  it 'should load available deployment recipes'
  
end

describe Sprinkle::Actors::Capistrano, 'processing commands' do
  
  it 'should dynamically create a capistrano task containing the commands'
  it 'should invoke capistrano task after creation'
  
end

describe Sprinkle::Actors::Capistrano, 'generated task' do
  
  it 'should use sudo to invoke commands when so configured'
  it 'should generate a name for the task including supplied parameters'
  it 'should be applicable for the supplied roles'
  
end