require 'capistrano/cli'

module Sprinkle
  module Actors
    # The Capistrano actor uses Capistrano to define your roles and deliver 
    # commands to your remote servers.  You'll need the capistrano gem installed.
    #
    # The only configuration option is to specify a recipe.
    #
    #   deployment do
    #     delivery :capistrano do
    #       recipe 'deploy'
    #       recipe 'more'
    #     end
    #   end
    #
    # Recipes is given a list of files which capistrano will include and load.
    # These recipes are mainly to set variables such as :user, :password, and to 
    # set the app domain which will be sprinkled. 
    class Capistrano < Actor
      attr_accessor :config, :loaded_recipes #:nodoc:

      def initialize(&block) #:nodoc:
        @installer = nil
        @config = ::Capistrano::Configuration.new
        @config.logger.level = Sprinkle::OPTIONS[:verbose] ? ::Capistrano::Logger::INFO : ::Capistrano::Logger::IMPORTANT
        @config.set(:password) { ::Capistrano::CLI.password_prompt }
        
        @config.set(:_sprinkle_actor, self)
        
        def @config.recipes(script)
          _sprinkle_actor.recipes(script)
        end

        if block
          @config.instance_eval(&block)
        else
          @config.load "Capfile" if File.exist?("Capfile")
        end
      end
      
      def sudo? #:nodoc:
        @config.fetch(:run_method, :run) == :sudo
      end
      
      def sudo_command #:nodoc:
        @config.sudo
      end
      
      # Determines if there are any servers for the given roles
      def servers_for_role?(roles) #:nodoc:
        roles=Array(roles)
        roles.any? { |r| @config.roles.keys.include?(r) }
      end
      

      # Defines a recipe file which will be included by capistrano. Use these
      # recipe files to set capistrano specific configurations. Default recipe
      # included is "deploy." But if any other recipe is specified, it will
      # include that instead. Multiple recipes may be specified through multiple
      # recipes calls, an example:
      #
      #   deployment do
      #     delivery :capistrano do
      #       recipe 'deploy'
      #       recipes 'magic_beans', 'normal_beans'
      #     end
      #   end
      def recipe(scripts)
        @loaded_recipes ||= []
        Array(scripts).each do |script|
          @config.load script
          @loaded_recipes << script        
        end
      end
      
      def recipes(scripts) #:nodoc:
        recipe(scripts)
      end
      
      def install(installer, roles, opts = {}) #:nodoc:
        @installer = installer
        process(installer.package.name, installer.install_sequence, roles, opts)
      rescue ::Capistrano::CommandError => e
        raise_error(e)
      ensure
        @installer = nil
      end
      
      def verify(verifier, roles, opts = {}) #:nodoc:
        process(verifier.package.name, verifier.commands, roles)
      rescue ::Capistrano::CommandError
        return false
      end
            
      def process(name, commands, roles, opts = {}) #:nodoc:
        inst=@installer
        @log_recorder = log_recorder = Sprinkle::Utility::LogRecorder.new
        commands = commands.map {|x| rewrite_command(x)}
        define_task(name, roles) do
          via = fetch(:run_method, :run)
          commands.each do |command|
            if command == :TRANSFER
              opts.reverse_merge!(:recursive => true)
              upload inst.sourcepath, inst.destination, :via => :scp, 
                :recursive => opts[:recursive]
            elsif command == :RECONNECT
              teardown_connections_to(sessions.keys)
            else
              # this reset the log
              log_recorder.reset command
              invoke_command(command, {:via => via}) do |ch, stream, out|
                ::Capistrano::Configuration.default_io_proc.call(ch, stream, out) if Sprinkle::OPTIONS[:verbose]
                log_recorder.log(stream, out)
              end
            end
          end
        end
        run_task(name, opts)
      end
			
      private
            
        # rip out any double sudos from the beginning of the command
        def rewrite_command(cmd)
          return cmd if cmd.is_a?(Symbol)
          via = @config.fetch(:run_method, :run)
          if via == :sudo and cmd =~ /^#{sudo_command}/
            cmd.gsub(/^#{sudo_command}\s?/,"")
          else
            cmd
          end
        end
        
        def raise_error(e)
          details={:command => @log_recorder.command, :code => "??", 
            :message => e.message,
            :hosts => e.hosts,
            :error => @log_recorder.err, :stdout => @log_recorder.out}
          raise Sprinkle::Errors::RemoteCommandFailure.new(@installer, details, e)
        end
      
        def run_task(task, opts={})
          run(task)
          true
        end

        # REVISIT: can we set the description somehow?
        def define_task(name, roles, &block)
          @config.task task_sym(name), :roles => roles, &block
        end

        def run(task)
          @config.send task_sym(task)
        end

        def task_sym(name)
          "install_#{name.to_task_name}".to_sym
        end
    end
  end
end


=begin

# channel: the SSH channel object used for this response
# stream: either :err or :out, for stderr or stdout responses
# output: the text that the server is sending, might be in chunks
run "apt-get update" do |channel, stream, output|
   if output =~ /Are you sure?/
     answer = Capistrano::CLI.ui.ask("Are you sure: ")
     channel.send_data(answer + "\n")
   else
     # allow the default callback to be processed
     Capistrano::Configuration.default_io_proc.call[channel, stream, output]
   end
 end



 You can tell subversion to use a different username+password by
 setting a couple variables:
    set :svn_username, "my svn username"
    set :svn_password, "my svn password"
 If you don't want to set the password explicitly in your recipe like
 that, you can make capistrano prompt you for it like this:
    set(:svn_password) { Capistrano::CLI.password_prompt("Subversion
 password: ") }
 - Jamis
=end
