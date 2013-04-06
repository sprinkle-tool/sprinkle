require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Runner do

	before do
		@package = mock(Sprinkle::Package, :name => 'package', :sudo? => false)
	end

	def create_runner(*cmds)
	  options=cmds.extract_options!
		Sprinkle::Installers::Runner.new(@package, cmds, options)
	end

	describe 'when created' do
		it 'should accept a single cmd to run' do
			@installer = create_runner 'teste'
			@installer.cmds.should == ['teste']
		end
		
		it 'should accept an array of commands to run' do
			@installer = create_runner ['teste', 'world']
			@installer.cmds.should == ['teste', 'world']
			@installer.install_sequence.should == ['teste', 'world']
	  end
	end

	describe 'during installation' do
		
		it 'should use sudo if specified locally' do
		  @installer = create_runner 'teste', :sudo => true
		  @install_commands = @installer.send :install_commands
		  @install_commands.should == ['sudo teste']
	  end
	  
	  it "should accept multiple commands" do
	    @installer = create_runner 'teste', 'test2'
	    @install_commands = @installer.send :install_commands
	    @install_commands.should == ['teste','test2']
    end

		it 'should run the given command for all specified packages' do
		  @installer = create_runner 'teste'
			@install_commands = @installer.send :install_commands
			@install_commands.should == ['teste']
		end
	end
end
