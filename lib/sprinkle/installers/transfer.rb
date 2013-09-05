require 'tempfile'

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
    # As an alternative to :recursive, you can use the :tarball option. When this is
    # supplied, the source file(s) are first packed in a tar.gz archive, then
    # transferred to a temp dir and finally unpacked at the destination. This is usually
    # much faster when transferring many small files (Such as a typical rails application)
    # You can optionally supply :exclude, which is an array of glob-patterns to not
    # include in the tarball
    #
    #   package :webapp do
    #     transfer 'app/', '/var/www/' do
    #       tarball :exclude => %w(.git log/*)
    #     end
    #   end
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

      # Include deprecated code
      # Mainly, this makes it easier to see where to cut, when next major version comes along
      DEPRECATED = true #:nodoc:

      api do
        def transfer(source, destination, options = {}, &block)
          options.reverse_merge!(:binding => binding())
          install Transfer.new(self, source, destination, options, &block)
        end
      end

      def initialize(parent, source, destination, options = {}, &block) #:nodoc:
        options.reverse_merge! :recursive => true
        
        @source = source # Original source
        @sourcepath = source # What the actor will transfer (may be the same as @source)
        @final_destination = destination # Final destination
        @destination = destination # Where the actor will place the file (May be same as @final_destination)
        
        owner(options[:owner]) if options[:owner]
        mode(options[:mode]) if options[:mode]
        tarball(options[:tarball]) if options[:tarball]
        
        super parent, options, &block
        
        if DEPRECATED
          @binding = options[:binding]
          options[:render] = true if source_is_template?
          options[:recursive] = false if options[:render]
          setup_rendering if options[:render]
        end
        setup_tarball if tarball?
        setup_sudo if sudo?
      end

      def tarball(options = {})
        @tarball = true
        @exclude = options===true ? [] : options[:exclude]
      end

      def owner(owner)
        @owner = owner
        post(:install, "#{sudo_cmd}chown -R #{@owner} #{@final_destination}")
      end

      def mode(mode)
        @mode = mode
        post(:install, "#{sudo_cmd}chmod -R #{@mode} #{@final_destination}")
      end

      def tarball?
        @tarball
      end

      def install_commands
        Commands::Transfer.new(sourcepath, destination,
          :recursive => options[:recursive])
      end

      if DEPRECATED
        def render_template(template, context, prefix)
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
          @source.split("\n").size > 1
        end
        
        def setup_rendering
          ActiveSupport::Deprecation.warn("transfer :render is depreciated, please use the `file` installer now.")
          ActiveSupport::Deprecation.warn("transfer :render will be removed from Sprinkle v0.8")
          if @options[:render]
            raise "Incompatible combination of options :render and :tarball" if tarball?
            if @options[:locals]
              context = {}
              @options[:locals].each_pair do |k,v|
                if v.respond_to?(:call)
                  context[k] = v.call
                else
                  context[k] = v
                end
              end
            else
              context = @binding
            end

            @tempfile = render_template_file(@source, context, @package.name).path
            @sourcepath = @tempfile
            @options[:recursive] = false
          end
        end
      end
        
      def setup_tarball
        # tar files locally and scp to a temp location
        # then untar after transfer
        tar_options = @exclude.map {|glob| "--exclude \"#{glob}\" " }.join('')
        @tempfile = make_tmpname
        local_command = "cd '#{@source}' ; #{local_tar_bin} -zcf '#{@tempfile}' #{tar_options}."
        logger.debug "    --> Compressing #{@source} locally"
        raise "Unable to tar #{@source}" unless system(local_command)
        @sourcepath = @tempfile
        @destination = "/tmp/#{File.basename(@tempfile)}"
        post(:install).unshift [
          "#{sudo_cmd}tar -zxf '#{@destination}' -C '#{@final_destination}'",
          "#{sudo_cmd}rm '#{@destination}'"
        ]
      end
      
      def setup_sudo
        @destination = "/tmp/sprinkle_#{File.basename(@destination)}"
        # make sure we push the move ahead of any other post install tasks
        # a user may have requested
        post(:install).unshift "#{sudo_cmd}mv #{@destination} #{@final_destination}"
      end

      protected
        def local_tar_bin
          @local_tar_bin ||= (`uname` =~ /Darwin/ ? "COPYFILE_DISABLE=true /usr/bin/gnutar" : "tar")
        end

        def post_process
          return unless @tempfile
          logger.debug "    --> Deleting local temp file"
          File.delete @tempfile
        end

        def make_tmpname
          Dir::Tmpname.make_tmpname(['/tmp/sprinkle-', '.tar.gz'], nil)
        end

    end
  end
end
