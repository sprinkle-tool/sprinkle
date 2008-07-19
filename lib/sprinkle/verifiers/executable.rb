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
      
      # Checks if <tt>path</tt> is an executable script. This verifier is "smart" because
      # if the path contains a forward slash '/' then it assumes you're checking an 
      # absolute path to an executable. If no '/' is in the path, it assumes you're
      # checking for a global executable that would be available anywhere on the command line.
      def has_executable(path)
        # Be smart: If the path includes a forward slash, we're checking
        # an absolute path. Otherwise, we're checking a global executable
        if path.include?('/')
          @commands << "test -x #{path}"
        else
          @commands << "[ -n \"`which #{path}`\"]"
        end
      end
    end
  end
end