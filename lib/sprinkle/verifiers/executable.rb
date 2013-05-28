module Sprinkle
  module Verifiers
    # = Executable Verifier
    #
    # Contains a verifier to check the existance of an executable
    # script on your server.
    # 
    # == Example Usage
    #
    # First, absolute path to an executable:
    #
    #   verify { has_executable '/usr/special/secret/bin/scipt' }
    #
    # Second, a global executable which would be available anywhere on the
    # command line:
    #
    #   verify { has_executable 'grep' }
    module Executable
      Sprinkle::Verify.register(Sprinkle::Verifiers::Executable)
      
      # Checks if <tt>path</tt> is an executable script using which
      # - accepts both absolute paths and binary names with no path
      def has_executable(path)
        @commands << "which #{path}"
      end

      # Same as has_executable but with checking for e certain version number.
      # Last option is the parameter to append for getting the version (which
      # defaults to "-v").
      def has_executable_with_version(path, version, get_version = '-v')
        if path.include?('/')
          @commands << "[ -x #{path} -a -n \"`#{path} #{get_version} 2>&1 | egrep -e \\\"#{version}\\\"`\" ]"
        else
          @commands << "[ -n \"`echo \\`which #{path}\\``\" -a -n \"`\\`which #{path}\\` #{get_version} 2>&1 | egrep -e \\\"#{version}\\\"`\" ]"
        end
      end

      # Same as has_executable but checking output of a certain command
      # with grep.
      def has_version_in_grep(cmd, version)
        @commands << "[ -n \"`#{cmd} 2> /dev/null | egrep -e \\\"#{version}\\\"`\" ]"
      end
    end
  end
end