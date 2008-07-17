module Sprinkle
  module Verifiers
    module File
      Sprinkle::Verify.register(Sprinkle::Verifiers::File)
      
      def has_file(path)
        @commands << "test -f #{path}"
      end
    end
  end
end