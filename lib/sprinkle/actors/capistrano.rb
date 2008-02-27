require 'capistrano/cli'

module Sprinkle
  module Actors
    class Capistrano
      
      def initialize
        @config = ::Capistrano::Configuration.new
        @config.logger.level = ::Capistrano::Logger::TRACE
        @config.set(:password) { ::Capistrano::CLI.password_prompt }        
        @config.load "deploy" # normally config/deploy in rails
      end
      
      # better name
      
      def process(name, commands, roles)
        define_task(name, roles) do
          via = fetch(:run_method, :sudo)
          commands.each do |command|
            invoke_command command, :via => via
          end
        end
        run(name)
      end
      
      private
        
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

