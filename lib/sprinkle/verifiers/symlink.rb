module Sprinkle
  module Verifiers
    module Symlink
      Sprinkle::Verify.register(Sprinkle::Verifiers::Symlink)
      
      def has_symlink(symlink, file = nil)
        if file.nil?
          @commands << "test -L #{symlink}"
        else
          @commands << "test '#{file}' = `readlink #{symlink}`"
        end
      end
    end
  end
end