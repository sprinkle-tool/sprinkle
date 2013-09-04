require 'tempfile'

module Sprinkle
  module Installers
    # = File installer
    #
    # This installer creates a file on the remote server.
    #
    # == Example Usage
    #
    # Installing a nginx.conf onto remote servers
    #
    #   package :nginx_conf do
    #     file '/etc/nginx.conf', :content => File.read('files/nginx.conf'),
    #       :sudo => true
    #   end
    #
    # Sudo is only necessary when the user your sprinkle is running as does
    # not have necessarily permissions to create the file on its own.
    # Such as when the file is in /etc.
    #
    # Should you need to run commands before or after the file transfer (making
    # directories or changing permissions), you can use the pre/post :install directives.
    #
    # == Rendering templates
    #
    # Use the template render helper to render an ERB template to a remote file (you
    # can use variables in your templates by setting them as instance variables inside
    # your package.  Templates have access to package methods such as opts, args, etc.
    #
    #   package :nginx_conf do
    #     @nginx_port = 8080
    #     file '/etc/nginx.conf',
    #       :contents => render("nginx.conf")
    #       # ./templates/nginx.conf.erb or
    #       # ./templates/nginx.conf should contain the erb template
    #   end
    class FileInstaller < Installer
      attr_reader :sourcepath, :destination, :contents #:nodoc:

      api do
        def file(destination, options = {}, &block) #:nodoc:
          # options.merge!(:binding => binding())
          install FileInstaller.new(self, destination, options, &block)
        end
      end

      def initialize(parent, destination, options={}, &block) #:nodoc:
        @destination = destination
        @contents = options[:content] || options[:contents]
        raise "need :contents key for file" unless @contents
        super parent, options, &block

        # setup file attributes
        owner options[:owner] if options[:owner]
        mode options[:mode] if options[:mode]

        post_move_if_sudo
        setup_source
      end

      def install_commands #:nodoc:
        Commands::Transfer.new(sourcepath, destination)
      end

      # calls chown own to set the file ownership
      def owner(owner)
        @owner = owner
        post :install, "#{sudo_cmd}chown #{owner} #{@destination}"
      end

      # calls chmod to set the files permissions
      def mode(mode)
        @mode = mode
        post :install, "#{sudo_cmd}chmod #{mode} #{@destination}"
      end

      private

      def post_move_if_sudo
        return unless sudo? # perform the file copy in two steps if we're using sudo
        final = @destination
        @destination = "/tmp/sprinkle_#{File.basename(@destination)}"
        # make sure we push the move ahead of any other post install tasks
        # a user may have requested
        post(:install).unshift ["#{sudo_cmd}mv #{@destination} #{final}"]
      end

      def setup_source
        @file = Tempfile.new(@package.name.to_s)
        @file.print @contents
        @file.close
        @sourcepath = @file.path
      end

      def post_process
        @file.unlink
      end

    end
  end
end
