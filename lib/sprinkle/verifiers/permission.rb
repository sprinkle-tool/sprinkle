module Sprinkle
  module Verifiers
    # = Permission and ownership Verifier
    #
    # Contains a verifier to check the permissions and ownership of a file or directory.
    # 
    # == Example Usage
    #
    #   verify { has_permission '/etc/apache2/apache2.conf', 0644 }
    #
    #   verify { belongs_to_user '/etc/apache2/apache2.conf', 'noop' }
    #
    #   verify { belongs_to_user '/etc/apache2/apache2.conf', 1000 }
    #
    module Permission
      Sprinkle::Verify.register(Sprinkle::Verifiers::Permission)

      def has_permission(path, permission)
        @commands << "find #{path} -maxdepth 0 -perm #{permission} | egrep '.*'"
      end

      def belongs_to_user(path, user)
        if user.is_a?(Integer)
          @commands << "find #{path} -maxdepth 0 -uid #{user} | egrep '.*'"
        else
          @commands << "find #{path} -maxdepth 0 -user #{user} | egrep '.*'"
        end
      end

      def belongs_to_group(path, group)
        if group.is_a?(Integer)
          @commands << "find #{path} -maxdepth 0 -gid #{group} | egrep '.*'"
        else
          @commands << "find #{path} -maxdepth 0 -group #{group} | egrep '.*'"
        end
      end

    end
  end
end
