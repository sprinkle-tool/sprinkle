require File.dirname(__FILE__) + '/../spec_helper'

describe Sprinkle::Verify do
  before do
    @name = :package
    @package = package @name do
      gem 'nonexistent'
      verify 'moo' do
        # Check a file exists
        has_file 'my_file.txt'
        
        # Check that a file contains a substring
        file_contains 'my_file.txt', 'A sunny day on the lower east-side'
        
        # Check a directory exists
        has_directory 'mydir'
        
        # Check a symlink exists
        has_symlink 'mypointer'
        
        # Check a symlink points to a certain file
        has_symlink 'mypointer', 'myfile'
        
        # Check if an executable exists
        has_executable '/usr/bin/ruby'
        
        # Check if a global executable exists (in PATH)
        has_executable 'rails'
        
        # Check for a process
        has_process 'httpd'
        
        # Check that ruby can include files
        ruby_can_load 'a', 'b', 'c'
        
        # Check that a gem exists
        has_gem 'rails'
        has_gem 'rails', '2.1.0'
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
    
    it 'should do a grep to see if a file contains a text string' do
      @verification.commands.should include("grep 'A sunny day on the lower east-side' my_file.txt")
    end
    
    it 'should do a "test -d" on the has_directory check' do
      @verification.commands.should include('test -d mydir')
    end
    
    it 'should do a "test -L" to check something is a symbolic link' do
      @verification.commands.should include('test -L mypointer')
    end
    
    it 'should do a test equality to check a symlink points to a specific file' do
      @verification.commands.should include("test 'myfile' = `readlink mypointer`")
    end
    
    it 'should do a "test -x" to check for an executable' do
      @verification.commands.should include("test -x /usr/bin/ruby")
    end
    
    it 'should test the "which" command to look for a global executable' do
      @verification.commands.should include('[ -n "`echo \`which rails\``" ]')
    end
    
    it 'should test the process list to find a process' do
      @verification.commands.should include("ps aux | grep 'httpd' | grep -v grep")
    end
    
    it 'should check if ruby can include a, b, c' do
      @verification.commands.should include("ruby -e \"require 'rubygems';require 'a';require 'b';require 'c'\"")
    end
    
    it 'should check that a ruby gem is installed' do
      @verification.commands.should include("sudo gem list | grep -e '^rails (.*.*)$'")
      @verification.commands.should include("sudo gem list | grep -e '^rails (.*2\\.1\\.0.*)$'")
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
  
  describe 'with registering new verification modules' do
    module MyModule
      def rawr; end
    end
    
    it 'should not respond to rawr initially' do
      @verification.should_not respond_to(:rawr)
    end
    
    it 'should respond to rawr after registering the module' do
      Sprinkle::Verify.register(MyModule)
      @verification.should respond_to(:rawr)
    end
  end
end