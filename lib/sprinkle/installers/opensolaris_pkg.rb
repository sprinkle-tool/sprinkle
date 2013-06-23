module Sprinkle
  module Installers
    # The OpenSolaris package installer installs OpenSolaris packages.
    # 
    # == Example Usage
    #
    # Installing the magic_beans package.
    #
    #   package :magic_beans do
    #     opensolaris_pkg 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     opensolaris_pkg 'magic_beans', 'magic_sauce'
    #   end
    #
    # == Note
    # If you are using capistrano as the deployment method
    # you will need to add the following lines to your deploy.rb
    #
    #   set :sudo, 'pfexec'
    #   set :sudo_prompt, ''
    class OpensolarisPkg < PackageInstaller
      
      ##
      # installs the OpenSolaris packages passed
      # :method: opensolaris_pkg
      # :call-seq: opensolaris_pkg(*packages)
      auto_api

      protected

        def install_commands #:nodoc:
          "pkg install #{@packages.join(' ')}"
        end

    end
  end
end
