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

      # Checks to make sure <tt>path</tt> is a file on the remote server.
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
      def user_present(username)
        has_user username
      end
      def matches_local(localfile, remotefile, options={})
        raise "Couldn't find local file #{localfile}" unless ::File.exists?(localfile)
        require 'digest/md5'

        if options[:render]
          content = render_content(localfile, options)
        else
          content = ::File.read(localfile)
        end

        local_md5 = Digest::MD5.hexdigest(content)
        @commands << %{[ "X$(md5sum #{remotefile}|cut -d\\  -f 1)" = "X#{local_md5}" ]}
      end

      private
        def render_content(filename, binding_options)
          require 'erb'
          begin
            template  = ERB.new(::File.read filename)
            context   = binding_options[:binding] || hash_context(binding_options[:locals])
            template.result(context)
          rescue Object => e
            raise TemplateError.new(e, template, context)
          end
        end

        def hash_context(locals)
          require 'ostruct'
          OpenStruct.new(locals).instance_eval { binding }
        end
    end
  end
end
