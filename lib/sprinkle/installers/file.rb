require 'tempfile'

module Sprinkle
  module Installers
    class FileInstaller < Installer
      # = File installer
      #
      # This installer creates a file on the remote server.
      #
      # == Example Usage
      #
      # Installing a nginx.conf onto remote servers
      #
      #   package :nginx_conf do
      #     file '/etc/nginx.conf', :content => File.read('files/nginx.conf')
      #   end
      #
      # If you user has access to 'sudo' and theres a file that requires
      # priveledges to install, you can pass :sudo => true
      #
      #   package :nginx_conf do
      #     file '/etc/nginx.conf', :sudo => true,
      #       :content => File.read('files/nginx.conf')
      #   end
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
      attr_reader :sourcepath, :destination
      
      api do
        def file(destination, options = {}, &block)
          # options.merge!(:binding => binding())
          install FileInstaller.new(self, destination, options, &block)
        end
      end
      
      def initialize(parent, destination, options={}, &block) #:nodoc:
        @destination = destination
        @contents = options[:content] || options[:contents]
        raise "need :contents key for file" unless @contents
        super parent, options, &block
        
        post_move_if_sudo
        setup_source
        # setup file attributes
        owner options[:owner] if options[:owner]
        mode options[:mode] if options[:mode]
      end
      
      def install_commands
        :TRANSFER
      end
            
      def owner(owner)
        @owner = owner
        post :install, "#{sudo_cmd}chown #{owner} #{@orig_destination}"
      end
      
      def mode(mode)
        @mode = mode
        post :install, "#{sudo_cmd}chmod #{mode} #{@orig_destination}"
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
        file=Tempfile.new(@package.name.to_s)
        file.print(@contents)
        file.close
        @sourcepath = file.path
      end
      
    end
  end
end