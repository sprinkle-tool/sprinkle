module Sprinkle
  module Verifiers
    # = Users and groups Verifier
    #
    # Tests for the existance of users and groups.
    #
    # == Example Usage
    #
    #   verify do
    #     has_user 'ntp'
    #     has_user 'noone', :in_group => 'nobody'
    #     has_group 'nobody'
    #   end
    #
    module UsersGroups
      Sprinkle::Verify.register(Sprinkle::Verifiers::UsersGroups)
      
      # Tests that the user exists
      def has_user(user, opts = {})
        if opts[:in_group]
          @commands << "id -G #{user} | xargs -n1 echo | grep #{opts[:in_group]}"
        else
          @commands << "id #{user}"
        end
      end
      
      # Tests that the group exists
      def has_group(group)
        @commands << "id -g #{group}"
      end
    end
  end
end