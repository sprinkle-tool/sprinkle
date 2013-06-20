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
      
      def has_file(path)
        test "-f #{path}"
      end
      
      def no_file(path)
        test "! -f #{path}"
      end
      
      def md5_of_file(path, md5)
        test "\"`md5sum #{path} | cut -f1 -d' '`\" = \"#{md5}\""
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
        @commands << %{[ "X$(md5sum #{remotefile}|cut -d\\  -f 1)" = "X#{local}" ]}
      end
    end
  end
end
