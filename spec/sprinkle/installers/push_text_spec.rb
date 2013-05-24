require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::PushText do

  before do
    @package = mock(Sprinkle::Package, :name => 'package', :sudo? => false)
    @options = {:sudo => true}
  end

  def create_text(text, path, options={}, &block)
    # the old default
    options.reverse_merge!(:idempotent => false)
    Sprinkle::Installers::PushText.new(@package, text, path, options, &block)
  end

  describe 'when created' do

    it 'should accept a single package to install' do
      @installer = create_text 'crazy-configuration-methods', '/etc/doomed/file.conf'
      @installer.text.should == 'crazy-configuration-methods'
      @installer.path.should == '/etc/doomed/file.conf'
    end

  end

  describe 'during installation' do

    before do
      @installer = create_text 'another-hair-brained-idea', '/dev/mind/late-night' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end
    
    describe 'with idempotent' do
      before do
        @installer = create_text 'another-hair-brained-idea', '/dev/mind/late-night', :idempotent => true
        @install_commands = @installer.send :install_commands
      end
      it "should grep for existing of the string" do
        @install_commands.should == %q<grep -qPzo '^another\-hair\-brained\-idea$' /dev/mind/late-night || /bin/echo -e 'another-hair-brained-idea' |tee -a /dev/mind/late-night>
      end
    end
    
    describe 'with multiline idempotent' do
      before do
        mline = <<-MULTI
^search( [adnor]{2,3} rescue)?$
^fries( [adnor]{2,3} barbecue)?
^songs( [adnor]{2,3} autocue)?
MULTI
        @installer = create_text mline.strip, '/dev/mind/late-night', :idempotent => true
        @install_commands = @installer.send :install_commands
      end
      it "should grep for existence of the string" do
        @install_commands.should == %q<grep -qPzo '^\^search\(\ \[adnor\]\{2,3\}\ rescue\)\?\$\n\^fries\(\ \[adnor\]\{2,3\}\ barbecue\)\?\n\^songs\(\ \[adnor\]\{2,3\}\ autocue\)\?$' /dev/mind/late-night || /bin/echo -e '^search( [adnor]{2,3} rescue)?$\n^fries( [adnor]{2,3} barbecue)?\n^songs( [adnor]{2,3} autocue)?' |tee -a /dev/mind/late-night>
      end
    end
    
    describe 'with sudo' do
      before do
        @installer = create_text 'another-hair-brained-idea', '/dev/mind/late-night', :sudo => true
        @install_commands = @installer.send :install_commands
      end
      it 'should invoke sudo if sudo option passed' do
        @install_commands.should == %q[/bin/echo -e 'another-hair-brained-idea' |sudo tee -a /dev/mind/late-night]
      end
    end

    it 'should invoke the push text installer for all specified packages' do
      @install_commands.should == %q[/bin/echo -e 'another-hair-brained-idea' |tee -a /dev/mind/late-night]
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', "/bin/echo -e 'another-hair-brained-idea' |tee -a /dev/mind/late-night", 'op2' ]
    end

  end
  
  describe 'running with sudo' do
    before do
      @installer = create_text "a special user", "/dev/mind/the-day-after", :sudo => true
      @install_commands = @installer.send :install_commands
    end
    
    it "should invoke the push installer with sudo" do
      @install_commands.should == %q[/bin/echo -e 'a special user' |sudo tee -a /dev/mind/the-day-after]
    end
  end
  
  describe 'sending a string with special characters' do
    
    it "should not escape an ampersand" do
      @installer = create_text "bob & lucy", "/dev/mind/the-day-after"
      @install_commands = @installer.send :install_commands
      @install_commands.should == %q[/bin/echo -e 'bob & lucy' |tee -a /dev/mind/the-day-after]
    end
    
    it "should not escape a slash" do
      @installer = create_text "bob/lucy", "/dev/mind/the-day-after"
      @install_commands = @installer.send :install_commands
      @install_commands.should == %q[/bin/echo -e 'bob/lucy' |tee -a /dev/mind/the-day-after]
    end
  end
  
  describe 'sending a string with single quotes' do
    before do
      @installer = create_text "I'm a string with a single quote", "/dev/mind/the-day-after"
      @install_commands = @installer.send :install_commands
    end
    
    it "should correctly encode the single quote character" do
      @install_commands.should == %q[/bin/echo -e 'I'\''m a string with a single quote' |tee -a /dev/mind/the-day-after]
    end
  end

end
