module Sprinkle
  module Verifiers
    # = File Verifier
    #
    # Contains a verifier to check the existance of a file.
    #
    # == Example Usage
    #
    #   verify { has_file '/etc/apache2/apache2.conf' }
    #
    #   verify { file_contains '/etc/apache2/apache2.conf', 'mod_gzip'}
    #
    module File
      Sprinkle::Verify.register(Sprinkle::Verifiers::File)

      # tests that the file <tt>path</tt> exists
      def has_file(path)
        test "-f #{path}"
      end

      # Tests that the directory <tt>dir</tt> exists.
      def has_directory(dir)
        test "-d #{dir}"
      end

      # Checks that <tt>symlink</tt> is a symbolic link. If <tt>file</tt> is
      # given, it checks that <tt>symlink</tt> points to <tt>file</tt>
      def has_symlink(symlink, file = nil)
        if file.nil?
          test "-L #{symlink}"
        else
          test "'#{file}' = `readlink #{symlink}`"
        end
      end

      def no_file(path)
        test "! -f #{path}"
      end

      def md5_of_file(path, md5)
        test "\"`#{sudo_cmd}md5sum #{path} | cut -f1 -d' '`\" = \"#{md5}\""
      end

      def sha1_of_file(path, sha1)
        test "\"`#{sudo_cmd}sha1sum #{path} | cut -f1 -d' '`\" = \"#{sha1}\""
      end

      def file_contains(path, text)
        @commands << "grep '#{text}' #{path}"
      end

      # TODO: remove 0.9
      def user_present(username)
        ActiveSupport::Deprecation.warn("user_present is depreciated.  Use has_user instead.")
        has_user username
      end

      def matches_local(localfile, remotefile, mode=nil)
        raise "Couldn't find local file #{localfile}" unless ::File.exists?(localfile)
        require 'digest/md5'
        local = Digest::MD5.hexdigest(::File.read(localfile))
        md5_of_file remotefile, local
      end
    end
  end
end
