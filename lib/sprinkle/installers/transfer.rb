module Sprinkle
  module Installers
    # Beware, strange "installer" coming your way.
    #
    # = Text configuration installer
    #
    # This installer pushes simple configuration into a file.
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
    # its known as file_contains, it will test that a file indeed
    # contains a substring that you send it.
    #
    class Transfer < Installer
      attr_accessor :source, :destination #:nodoc:

      def initialize(parent, source, destination, options={}, &block) #:nodoc:
        super parent, options, &block
        @source = source
        @destination = destination
      end

			def install_commands
				nil
			end
			
      def process(roles) #:nodoc:
        assert_delivery

        if logger.debug?
          logger.debug "transfer: #{@source} -> #{@destination} for roles: #{roles}\n"
        end

        unless Sprinkle::OPTIONS[:testing]
					pre = pre_commands(:install)
					unless pre.empty?
						sequence = pre; sequence = sequence.join('; ') if sequence.is_a? Array
						logger.info "#{@package.name} pre-transfer commands: #{sequence} for roles: #{roles}\n"
						@delivery.process sequence
					end
					
          logger.info "--> Transferring #{@source} to #{@destination} for roles: #{roles}"
          @delivery.transfer(@package.name, @source, @destination, roles)

					post = post_commands(:install)
					unless post.empty?
						sequence = post; sequence = sequence.join('; ') if sequence.is_a? Array
						logger.info "#{@package.name} post-transfer commands: #{sequence} for roles: #{roles}\n"
						@delivery.process sequence
					end
        end
      end
    end
  end
end
