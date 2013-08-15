require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::ReplaceText do

  before do
    @package = double(Sprinkle::Package, :name => 'package', :sudo? => false)
  end

  def create_replacement_text(regex, text, path, options={}, &block)
    Sprinkle::Installers::ReplaceText.new(@package, regex, text, path, options, &block)
  end

  describe 'when created' do

    it 'should accept text to replace, replacement, and path' do
      @installer = create_replacement_text 'text_to_replace', 'new_text', '/etc/example/foo.conf'
      @installer.regex.should eq 'text_to_replace'
      @installer.text.should eq 'new_text'
      @installer.path.should eq '/etc/example/foo.conf'
    end

    it 'should not escape original search string and replacement' do
      @installer = create_replacement_text "some option with 'quotes' & ampersand", "other 'quotes' & ampersand", '/etc/example/foo.conf'
      @installer.regex.should eq %q[some option with 'quotes' & ampersand]
      @installer.text.should eq %q[other 'quotes' & ampersand]
      @installer.path.should eq '/etc/example/foo.conf'
    end

  end

  describe 'during installation' do

    before do
      @installer = create_replacement_text 'bad option', 'super option', '/etc/brand/new.conf' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the replace text installer for all specified packages' do
      @install_commands.should eq %q[sed -i 's/bad option/super option/g' /etc/brand/new.conf]
    end

    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should eq [ 'op1', "sed -i 's/bad option/super option/g' /etc/brand/new.conf", 'op2' ]
    end

    it 'should correctly escape search string and replacement' do
      installer = create_replacement_text "some option with 'quotes' & ampersand", "other 'quotes' & ampersand", '/etc/example/foo.conf'
      installer.send(:install_commands).should eq "sed -i 's/some option with '\\''quotes'\\'' \\& ampersand/other '\\''quotes'\\'' \\& ampersand/g' /etc/example/foo.conf"
    end
  end

end
