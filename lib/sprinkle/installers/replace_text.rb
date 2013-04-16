module Sprinkle
  module Installers
    # = Replace text installer
    #
    # This installer replaces a text with another one in a file.
    # 
    # == Example Usage
    #
    # Change ssh port in /etc/ssh/sshd_config
    #
    #   package :magic_beans do
    #     replace_text 'Port 22', 'Port 2500', '/etc/ssh/sshd_config'
    #   end
    #
    # If you user has access to 'sudo' and theres a file that requires
    # priveledges, you can pass :sudo => true 
    #
    #   package :magic_beans do
    #     replace_text 'Port 22', 'Port 2500', '/etc/ssh/sshd_config', :sudo => true
    #   end
    #
    # A special verify step exists for this very installer
    # its known as file_contains, it will test that a file indeed
    # contains a substring that you send it.
    #
    class ReplaceText < Installer
      attr_accessor :regex, :text, :path #:nodoc:
      
      api do
        def replace_text(regex, text, path, options={}, &block)
          install ReplaceText.new(self, regex, text, path, options, &block)
        end
      end

      def initialize(parent, regex, text, path, options={}, &block) #:nodoc:
        super parent, options, &block
        @regex = regex
        @text = text
        @path = path
      end
      
      def announce
        log "--> Replace '#{@regex}' with '#{@text}' in file #{@path}"
      end

      protected
      
        def install_commands #:nodoc:
          "#{'sudo ' if option?(:sudo)}sed -i 's/#{@regex.gsub("'", "'\\\\''").gsub("/", "\\\\/").gsub("\n", '\n')}/#{@text.gsub("'", "'\\\\''").gsub("/", "\\\\/").gsub("\n", '\n').gsub('&', '\\\&')}/g' #{@path}"
        end

    end
  end
end
