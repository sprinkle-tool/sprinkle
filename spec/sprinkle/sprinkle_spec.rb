require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle do

  it 'should automatically extend Object to support package, policy and deployment DSL keywords' do
    %w( package policy deployment ).each do |keyword|
      Object.should respond_to(keyword.to_sym)
    end
  end

  it 'should default to production mode' do
    Sprinkle::OPTIONS[:testing].should be_false
  end

  it 'should automatically create a logger object on Kernel' do
    Object.should respond_to(:logger)
    logger.should_not be_nil
    logger.class.should == ActiveSupport::BufferedLogger
  end

  it 'should create a logger of level INFO' do
    logger.level.should == ActiveSupport::BufferedLogger::Severity::INFO
  end

end
