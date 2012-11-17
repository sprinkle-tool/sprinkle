module Sprinkle
  module Installers
    # = User Installer
    # 
    # The user installer configures a user with the specified string.
    # The user will be created using the operating system's +useradd+
    # utility, which will not prompt for user information. It should
    # also be noted that users created with this installer will not
    # have a password and will therefore not be able to log in until
    # +passwd+ is run against the user account.
    # 
    # == Configuration Options
    # 
    # The user installer has only one option:
    # 
    # * <b>option</b> - Options to be passed to +useradd+
    # 
    # == Example Usage
    # 
    # First, a simple user, no configuration:
    # 
    #   package :magic_beans do
    #     user 'awesomeguy'
    #   end
    # 
    # Second, specifying an option:
    # 
    #   package :magic_beans do
    #     user 'awesomeguy' do
    #       option 'comment "He actually is pretty awesome"'
    #     end
    #   end
    # 
    # Third, specifying some hooks:
    # 
    #   package :magic_beans do
    #     user 'awesomeguy' do
    #       option 'comment "He actually is pretty awesome"'
    # 
    #       post :install { 'adduser awesomeguy www-data' }
    #     end
    #   end
    # 
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as
    # its parameter.
    class User < Installer
      attr_accessor :username
      
      def initialize(parent, username, options = {}, &block)
        super parent, options, &block
        @username = username
      end
      
      protected 
      
        def install_commands
          # User useradd instead of adduser so it's quiet
          command = "useradd #{@username} --create-home "

          extras = {
            :option  => '-'
          }

          extras.inject(command) { |m, (k, v)|  m << create_options(k, v) if options[k]; m }

          command
        end
      
      private
      
        def create_options(key, prefix) #:nodoc:
          @options[key].first.inject('') { |m, option| m << "#{prefix}-#{option} "; m }
        end
      
    end
  end
end
