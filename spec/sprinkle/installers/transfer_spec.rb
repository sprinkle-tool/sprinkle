require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::Transfer do
  include Sprinkle::Deployment

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
    @empty = Proc.new { }
    @delivery = mock(Sprinkle::Deployment, :process => true)
		@source = 'source'
		@destination = 'destination'
    @installer = create_transfer(@source, @destination)
    @roles = []
    @deployment = deployment do
      delivery :capistrano
      installer do; prefix '/usr/bin'; end
    end
  end
  
  def create_transfer(source, dest, options={}, &block)
    i = Sprinkle::Installers::Transfer.new(@package, source, dest, options, &block)
    i.delivery = @delivery
		i
  end
  
  describe 'when created' do
    it 'should accept a single package to install' do
      @installer.source.should == @source
      @installer.destination.should == @destination
    end
  end
  
  describe 'during installation' do
    before do
      @installer = create_transfer @source, @destination do
        pre :install, 'op1'
        post :install, 'op2'
      end
    end

		it "should call the pre and post install commands around the file transfer" do
			delivery = @installer.delivery
			
			delivery.should_receive(:process).with(@package.name, 'op1', @roles).once.ordered.and_return
      delivery.should_receive(:transfer).with(@package.name, @source, @destination, @roles).ordered.and_return
			delivery.should_receive(:process).with(@package.name, 'op2', @roles).once.ordered.and_return
		end		
  
		after do
      @installer.process @roles
    end
  end
end
