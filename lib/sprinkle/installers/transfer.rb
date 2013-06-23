module Sprinkle
  module Installers
    # = File transfer installer
    #
    # This installer copies files from the local disk to remote servers using SCP.
    # Symbolic links will be followed and the files copied, but the symbolic links
    # themselves will not be preserved.  That's just how SCP works.
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
    # :recursive => false, although it will not be obeyed when using the Vlad actor.
    #
    # Should you need to run commands before or after the file transfer (making
    # directories or changing permissions), you can use the pre/post :install directives
    # and they will be run.
    # 
    # == Rendering templates
    #
    # Rendering templates with transfer has been depreciated.  Please see the file
    # installer if you want to use templates.
    class Transfer < Installer
      attr_accessor :source, :destination, :sourcepath #:nodoc:
      
      api do
        def transfer(source, destination, options = {}, &block)
          options.reverse_merge!(:binding => binding())
          install Transfer.new(self, source, destination, options, &block)
        end
      end

      def initialize(parent, source, destination, options={}, &block) #:nodoc:
        @source = source
        @destination = destination
        @orig_destination = destination
        super parent, options, &block
        @binding = options[:binding]
        if sudo? # perform the transfer in two steps if we're using sudo
          final = @destination
          @destination = "/tmp/sprinkle_#{File.basename(@destination)}"
          # make sure we push the move ahead of any other post install tasks
          # a user may have requested
          post(:install).unshift ["#{sudo_cmd}mv #{@destination} #{final}"]
        end
        owner(options[:owner]) if options[:owner]
        mode(options[:mode]) if options[:mode]

        options[:render]=true if source_is_template?
        options[:recursive]=false if options[:render]
      end
      
      def owner(owner)
        @owner = owner
        post :install, "#{sudo_cmd}chown #{owner} #{@orig_destination}"
      end
      
      def mode(mode)
        @mode = mode
        post :install, "#{sudo_cmd}chmod #{mode} #{@orig_destination}"
      end

      def install_commands
        :TRANSFER
      end

      def render_template(template, context, prefix)
        require 'tempfile'

        output = @package.template(template, context)

        final_tempfile = Tempfile.new(prefix.to_s)
        final_tempfile.print(output)
        final_tempfile.close
        final_tempfile
      end

      def render_template_file(path, context, prefix)
        template = source_is_template? ? path : File.read(path)
        tempfile = render_template(template, context, @package.name)
        tempfile
      end
      
      def source_is_template?
        @source.split("\n").size>1
      end

      def process(roles) #:nodoc:
        logger.debug "transfer: #{@source} -> #{@destination} for roles: #{roles}\n"

        return if Sprinkle::OPTIONS[:testing]

        if options[:render]
          ActiveSupport::Deprecation.warn("transfer :render is depreciated, please use the `file` installer now.")
          ActiveSupport::Deprecation.warn("transfer :render will be removed from Sprinkle v0.8")
          if options[:locals]
            context = {}
            options[:locals].each_pair do |k,v|
              if v.respond_to?(:call)
                context[k] = v.call
              else
                context[k] = v
              end
            end
          else
            context = @binding
          end

          tempfile = render_template_file(@source, context, @package.name)
          @sourcepath = tempfile.path
          @options[:recursive] = false
        else
          @sourcepath = @source
        end

        logger.debug "    --> Transferring #{sourcepath} to #{@orig_destination} for roles: #{roles}"
        @delivery.install(self, roles, :recursive => @options[:recursive])
      end
    end
  end
end
