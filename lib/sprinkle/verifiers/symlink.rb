module Sprinkle
  module Verifiers
    # = Symlink Verifier
    #
    # Contains a verifier to check the existance of a symbolic link.
    # 
    # == Example Usage
    #
    # First, checking for the existence of a symlink:
    #
    #   verify { has_symlink '/usr/special/secret/pointer' }
    #
    # Second, checking that the symlink points to a specific place:
    #
    #   verify { has_symlink '/usr/special/secret/pointer', '/usr/local/realfile' }
    module Symlink
      Sprinkle::Verify.register(Sprinkle::Verifiers::Symlink)
      
      # Checks that <tt>symlink</tt> is a symbolic link. If <tt>file</tt> is 
      # given, it checks that <tt>symlink</tt> points to <tt>file</tt>
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