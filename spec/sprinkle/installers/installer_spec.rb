require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Installer do
  include Sprinkle::Deployment

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
    @empty = Proc.new { }
    @sequence = ['op1', 'op2']
    @delivery = mock(Sprinkle::Deployment, :process => true)
    @installer = create_installer
    @installer.delivery = @delivery
    @roles = []
    @deployment = deployment do
      delivery :capistrano
      installer do; prefix '/usr/bin'; end
    end
  end

  def create_installer(&block)
    installer = Sprinkle::Installers::Installer.new @package, &block
    installer.stub!(:puts).and_return

    # this is actually an abstract class so we'll insert a few fake install sequences
    class << installer
      def install_sequence
        ['op1', 'op2']
      end
    end

    installer
  end

  describe 'when created' do

    it 'should belong to a package' do
      @installer.package.should == @package
    end

    describe 'with a block to customize installer defaults' do

      it 'should accept an optional block to customize installers defaults' do
        @installer = create_installer do; prefix '/usr/local'; end
        @installer.prefix.should == '/usr/local'
      end

      it 'should override any deployment level defaults' do
        @installer = create_installer do; prefix '/usr/local'; end
        @installer.defaults(@deployment)
        @installer.prefix.should == '/usr/local'
      end
    end
  end

  describe 'during configuration' do

    before do
      @default = Proc.new { }
      @defaults = { :installer => @default }
      @deployment.stub!(:defaults).and_return(@defaults)
    end

    it 'should be configurable via external defaults' do
      @installer.should respond_to(:defaults)
    end

    it 'should select the defaults for the particular concrete installer class' do
      @deployment.should_receive(:defaults).and_return(@defaults)
      @defaults.should_receive(:[]).with(:installer).and_return(@default)
    end

    it 'should configure the installer delivery mechansim' do
      @installer.should_receive(:instance_eval)
    end

    it 'should maintain an options hash set arbitrarily via method missing' do
      @installer.instance_eval do
        hsv 'gts'
      end
      @installer.hsv.should == 'gts'
    end

    after do
      @installer.defaults(@deployment)
    end

  end

  describe 'during installation' do

    it 'should request the install sequence from the concrete class' do
      @installer.should_receive(:install_sequence).and_return(@sequence)
    end

    describe 'when testing' do

      before do
        Sprinkle::OPTIONS[:testing] = true
        @logger = mock(ActiveSupport::BufferedLogger, :debug => true, :debug? => true)
      end

      it 'should not invoke the delivery mechanism with the install sequence' do
        @delivery.should_not_receive(:process)
      end

      it 'should print the install sequence to the console' do
        @installer.should_receive(:logger).twice.and_return(@logger)
      end

    end

    describe 'when in production' do
      it 'should invoke the delivery mechanism to process the install sequence' do
        @delivery.should_receive(:process).with(@package.name, @sequence, @roles)
      end
    end

    after do
      @installer.process(@roles)
      Sprinkle::OPTIONS[:testing] = false
    end

  end

end
