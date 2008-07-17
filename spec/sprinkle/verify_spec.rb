require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Verify do
  before do
    @name = :package
    @package = package @name do
      gem 'nonexistent'
      verify 'moo' do
        has_file 'my_file.txt'
        has_directory 'mydir'
      end
    end
    @verification = @package.verifications[0]
    @delivery = mock(Sprinkle::Deployment, :process => true)
    @verification.delivery = @delivery
  end
  
  describe 'when created' do
    it 'should raise error without a block' do
      lambda { Verify.new(nil, '') }.should raise_error
    end
  end
  
  describe 'with checks' do
    it 'should do a "test -f" on the has_file check' do
      @verification.commands.should include('test -f my_file.txt')
    end
    
    it 'should do a "test -d" on the has_directory check' do
      @verification.commands.should include('test -d mydir')
    end
  end
  
  describe 'with configurations' do
    # Make sure it includes Sprinkle::Configurable
    it 'should respond to configurable methods' do
      @verification.should respond_to(:defaults)
    end
    
    it 'should default padding option to 4' do
      @verification.padding.should eql(4)
    end
  end
  
  describe 'with process' do
    it 'should raise an error when no delivery mechanism is set' do
      @verification.instance_variable_set(:@delivery, nil)
      lambda { @verification.process([]) }.should raise_error
    end
    
    describe 'when not testing' do
      before do
        # To be explicit
        Sprinkle::OPTIONS[:testing] = false
      end
      
      it 'should call process on the delivery with the correct parameters' do
        @delivery.should_receive(:process).with(@name, @verification.commands, [:app], true).once.and_return(true)
        @verification.process([:app])
      end
      
      it 'should raise Sprinkle::VerificationFailed exception when commands fail' do
        @delivery.should_receive(:process).once.and_return(false)
        lambda { @verification.process([:app]) }.should raise_error(Sprinkle::VerificationFailed) do |error|
          error.package.should eql(@package)
          error.description.should eql('moo')
        end
      end
    end
    
    describe 'when testing' do
      before do
        Sprinkle::OPTIONS[:testing] = true
        @logger = mock(ActiveSupport::BufferedLogger, :debug => true, :debug? => true)
      end
      
      it 'should not call process on the delivery' do
        @delivery.should_not_receive(:process)
      end

      it 'should print the install sequence to the console' do
        @verification.should_receive(:logger).twice.and_return(@logger)
      end
      
      after do
        @verification.process([:app])
        Sprinkle::OPTIONS[:testing] = false
      end
    end
  end
end