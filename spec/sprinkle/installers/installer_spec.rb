require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Installer do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
    @empty = Proc.new { }
    @sequence = ['op1', 'op2']
    @installer = create_installer
    @delivery = mock(Sprinkle::Deployment, :process => true)
    @installer.delivery = @delivery
    @roles = []
  end

  def create_installer
    installer = Sprinkle::Installers::Installer.new @package do; end
    installer.stub!(:puts).and_return
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

    it 'should accept an optional block to customize installers defaults'

  end

  describe 'during configuration' do

    it 'should be configurable via external defaults'

    it 'should select the defaults for the particular concrete installer class'

    it 'should configure the installer delivery mechansim'

    it 'should maintain an options hash set arbitrarily via method missing'

  end

  describe Sprinkle::Installers::Installer, 'during installation' do

    it 'should request the install sequence from the concrete class' do
      @installer.should_receive(:install_sequence).and_return(@sequence)
    end

    describe 'when testing' do

      before do
        Sprinkle::OPTIONS[:testing] = true
      end

      it 'should not invoke the delivery mechanism with the install sequence' do
        @delivery.should_not_receive(:process)
      end

      it 'should print the install sequence to the console' do
        @installer.should_receive(:puts)
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
