module Sprinkle
  module Verifiers
    module Directory
      Sprinkle::Verify.register(Sprinkle::Verifiers::Directory)
      
      def has_directory(dir)
        @commands << "test -d #{dir}"
      end
    end
  end
end