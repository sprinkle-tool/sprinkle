module Sprinkle
  module Installers
    # The user installer add users.  You may pass :flags as an option.
    #
    # == Example Usage
    #
    #   package :users do
    #     add_user 'admin', :flags => "--disabled-password"
    #
    #     verify do
    #       has_user 'admin', :in_group => "root"
    #     end
    #   end
    class User < Installer

      api do
        def add_user(username, options={},  &block)
          install User.new(self, username, options, &block)
        end
      end

      verify_api do
        def has_user(user, opts = {})
          if opts[:in_group]
            @commands << "id -nG #{user} | xargs -n1 echo | grep #{opts[:in_group]}"
          else
            @commands << "id #{user}"
          end
        end
      end

      def initialize(package, username, options = {}, &block) #:nodoc:
        super package, options, &block
        @username = username
      end

    protected

      def install_commands #:nodoc:
        noninteractive = " --gecos ,,,"
        flags = @options[:flags] || ""
        flags << noninteractive unless flags =~ /--gecos/
        "#{sudo_cmd}adduser #{flags.strip} #{@username}"
      end

    end
  end
end
