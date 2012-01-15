# Blatantly stole this from Chef
class TemplateError < RuntimeError
  attr_reader :original_exception, :context
  SOURCE_CONTEXT_WINDOW = 2 unless defined? SOURCE_CONTEXT_WINDOW

  def initialize(original_exception, template, context)
    @original_exception, @template, @context = original_exception, template, context
  end

  def message
    @original_exception.message
  end

  def line_number
    @line_number ||= $1.to_i if original_exception.backtrace.find {|line| line =~ /\(erubis\):(\d+)/ }
  end

  def source_location
    "on line ##{line_number}"
  end

  def source_listing
    return nil if line_number.nil?

    @source_listing ||= begin
      line_index = line_number - 1
      beginning_line = line_index <= SOURCE_CONTEXT_WINDOW ? 0 : line_index - SOURCE_CONTEXT_WINDOW
      source_size = SOURCE_CONTEXT_WINDOW * 2 + 1
      lines = @template.split(/\n/)
      contextual_lines = lines[beginning_line, source_size]
      output = []
      contextual_lines.each_with_index do |line, index|
        line_number = (index+beginning_line+1).to_s.rjust(3)
        output << "#{line_number}: #{line}"
      end
      output.join("\n")
    end
  end

  def to_s
    "\n\n#{self.class} (#{message}) #{source_location}:\n\n" +
      "#{source_listing}\n\n  #{original_exception.backtrace.join("\n  ")}\n\n"
  end
end

module Sprinkle
  module Installers
    # Beware, another strange "installer" coming your way.
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
    # If you pass the option :render => true, this tells transfer that the source file
    # is an ERB template to be rendered locally before being transferred (you can declare
    # variables in the package scope). When render is true, recursive is turned off. Note
    # you can also explicitly pass locals in to render with the :locals option.
    #
    #   package :nginx_conf do
    #     nginx_port = 8080
    #     transfer 'files/nginx.conf', '/etc/nginx.conf', :render => true
    #   end
    #
    # Finally, should you need to run commands before or after the file transfer (making
    # directories or changing permissions), you can use the pre/post :install directives
    # and they will be run.
    class Transfer < Installer
      attr_accessor :source, :destination, :sourcepath #:nodoc:

      def initialize(parent, source, destination, options={}, &block) #:nodoc:
        @source = source
        @destination = destination
        super parent, options, &block
        @binding = options[:binding]
        # perform the transfer in two steps if we're using sudo
        if sudo?
          final = @destination
          @destination = "/tmp/sprinkle_#{File.basename(@destination)}"
          post :install, "#{sudo_cmd}mv #{@destination} #{final}"
        end
        owner(options[:owner]) if options[:owner]
        mode(optinos[:mode]) if options[:mode]

        options[:recursive]=false if options[:render]
      end
      
      def owner(owner)
        @owner = owner
        post :install, "#{sudo_cmd}chown #{owner} #{destination}"
      end
      
      def mode(mode)
        @mode = mode
        post :install, "#{sudo_cmd}chmod #{mode} #{destination}"
      end

      def install_commands
        :TRANSFER
      end

      def self.render_template(template, context, prefix)
        require 'tempfile'
        require 'erubis'

        begin
          eruby = Erubis::Eruby.new(template)
          output = eruby.result(context)
        rescue Object => e
          raise TemplateError.new(e, template, context)
        end

        final_tempfile = Tempfile.new(prefix.to_s)
        final_tempfile.print(output)
        final_tempfile.close
        final_tempfile
      end

      def render_template(template, context, prefix)
        self.class.render_template(template, context, prefix)
      end

      def render_template_file(path, context, prefix)
        template = File.read(path)
        tempfile = render_template(template, context, @package.name)
        tempfile
      end

      def process(roles) #:nodoc:
        assert_delivery

        logger.debug "transfer: #{@source} -> #{@destination} for roles: #{roles}\n"

        return if Sprinkle::OPTIONS[:testing]

        if options[:render]
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
            # context = binding()
            context = @binding
          end

          tempfile = render_template_file(@source, context, @package.name)
          @sourcepath = tempfile.path
          logger.info "Rendering template #{@source} to temporary file #{sourcepath}"
          recursive = false
        else
          @sourcepath = @source
        end

        logger.info "--> Transferring #{sourcepath} to #{@destination} for roles: #{roles}"
        @delivery.install(self, roles, :recursive => @options[:recursive])
      end
    end
  end
end
