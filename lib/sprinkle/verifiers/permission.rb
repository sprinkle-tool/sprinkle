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
        arg = user.is_a?(Integer) ? "-uid" : "-user"
        @commands << "find #{path} -maxdepth 0 #{arg} #{user} | egrep '.*'"
      end

      def belongs_to_group(path, group)
        arg = group.is_a?(Integer) ? "-gid" : "-group"
        @commands << "find #{path} -maxdepth 0 #{arg} #{group} | egrep '.*'"
      end

    end
  end
end
