module Sprinkle
  module Installers
    # = Replace text installer
    #
    # This installer replaces a text matching the regex  with another one in a file.
    #
    # == Example Usage
    #
    # Change ssh port in /etc/ssh/sshd_config
    #
    #   package :magic_beans do
    #     replace_text 'Port [0-9]+', 'Port 2500', '/etc/ssh/sshd_config'
    #   end
    #
    # Because we use sed under the hood, the regex is extended regex.
    #
    # If you user has access to 'sudo' and theres a file that requires
    # privileges, you can pass :sudo => true
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

        def escape_sed_arg(s)
          escape_shell_arg(s).gsub("/", "\\\\/").gsub('&', '\\\&')
        end

        def install_commands #:nodoc:
          "#{sudo_cmd}sed -r -i 's/#{escape_sed_arg(@regex)}/#{escape_sed_arg(@text)}/g' #{@path}"
        end

    end
  end
end
