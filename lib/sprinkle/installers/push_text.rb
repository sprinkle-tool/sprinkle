module Sprinkle
  module Installers
    # Beware, strange "installer" coming your way.
    #
    # This push text installer pushes simple configuration into a file.
    # 
    # == Example Usage
    #
    # Installing magic_beans into apache2.conf
    #
    #   package :magic_beans do
    #     push_text 'magic_beans', '/etc/apache2/apache2.conf'
    #   end
    #
    # If you user has access to 'sudo' and theres a file that requires
    # priveledges, you can pass :sudo => true 
    #
    #   package :magic_beans do
    #     push_text 'magic_beans', '/etc/apache2/apache2.conf', :sudo => true
    #   end
    #
    # A special verify step exists for this very installer
    # its known as +file_contains+, it will test that a file indeed
    # contains a substring that you send it.
    #
    #   package :magic_beans do
    #     push_text 'magic_beans', '/etc/apache2/apache2.conf'
    #     verify do
    #       file_contains '/etc/apache2/apache2.conf', 'magic_beans'
    #     end
    #   end
    #
    class PushText < Installer
      attr_accessor :text, :path #:nodoc:
      
      api do
        def push_text(text, path, options = {}, &block)
          install PushText.new(self, text, path, options, &block)
        end
      end

      def initialize(parent, text, path, options={}, &block) #:nodoc:
        super parent, options, &block
        # by default we would not want to push the same thing over and over
        options.reverse_merge!(:idempotent => true)
        @text = text
        @path = path
      end

      protected

        def install_commands #:nodoc:
          "#{"#{sudo_cmd}grep \"^#{@text.gsub("'", "'\\\\''").gsub("\n", '\n')}$\" #{@path} || " if option?(:idempotent) }/bin/echo -e '#{@text.gsub("'", "'\\\\''").gsub("\n", '\n')}' |#{sudo_cmd}tee -a #{@path}"
        end

    end
  end
end
