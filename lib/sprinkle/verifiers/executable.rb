module Sprinkle
  module Verifiers
    module Executable
      Sprinkle::Verify.register(Sprinkle::Verifiers::Executable)
      
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