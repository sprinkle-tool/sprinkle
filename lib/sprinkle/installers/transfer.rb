module Sprinkle
  module Installers
    # Beware, strange "installer" coming your way.
    #
    # = File transfer installer
    #
    # This installer pushes files from the local disk to remote servers.
    # 
    # == Example Usage
    #
    # Installing a nginx.conf onto remote servers
    #
    #   package :nginx_conf do
    #     transfer 'files/nginx.conf', '/etc/nginx.conf'
    #   end
    #
    # If you user has access to 'sudo' and theres a file that requires
    # priveledges, you can pass :sudo => true 
    #
    #   package :nginx_conf do
    #     transfer 'files/nginx.conf', '/etc/nginx.conf', :sudo => true
    #   end
    #
		# By default, transfers are recursive and you can move whole directories
		# via this method. If you wish to disable recursive transfers, you can pass
		# recursive => false, although it will not be obeyed when using the Vlad actor.
    #
		# Finally, should you need to run commands before or after the file transfer (making
		# directories or changing permissions), you can use the pre/post :install directives
		# and they will be run.
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
						@delivery.process @package.name, sequence, roles
					end
					
          logger.info "--> Transferring #{@source} to #{@destination} for roles: #{roles}"
          @delivery.transfer(@package.name, @source, @destination, roles)

					post = post_commands(:install)
					unless post.empty?
						sequence = post; sequence = sequence.join('; ') if sequence.is_a? Array
						logger.info "#{@package.name} post-transfer commands: #{sequence} for roles: #{roles}\n"
						@delivery.process @package.name, sequence, roles
					end
        end
      end
    end
  end
end
