require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle do 

  it 'should automatically extend Object to support package, policy and deployment DSL keywords' do 
    %w( package policy deployment ).each do |keyword|
      Object.should respond_to(keyword.to_sym)
    end
  end
  
  it 'should default to production mode' do 
    Sprinkle::OPTIONS[:testing].should be_false
  end
  
end
