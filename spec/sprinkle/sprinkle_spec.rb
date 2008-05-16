require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle do 
  
  it 'should default to production mode' do 
    Sprinkle::OPTIONS[:testing].should be_false
  end
  
end
