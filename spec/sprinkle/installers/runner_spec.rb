require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Runner do

	before do
		@package = mock(Sprinkle::Package, :name => 'package')
	end

	def create_runner(cmd)
		Sprinkle::Installers::Runner.new(@package, cmd)
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

	describe 'during execution' do

		before do
			@installer = create_runner 'teste'
			@install_commands = @installer.send :install_commands
		end

		it 'should run the given command for all specified packages' do
			@install_commands.should == ['teste']
		end
	end
end
