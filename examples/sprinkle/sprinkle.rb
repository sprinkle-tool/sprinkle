#!/usr/bin/env sprinkle -c -s

# Example of the simplest Sprinkle script to install a single gem on a remote host. This
# particular script assumes that rubygems (and ruby, etc) are already installed on the remote
# host. To see a larger example of installing an entire ruby, rubygems, gem stack from source,
# please see the rails example.

# Packages, only sprinkle is defined in this world

package :sprinkle do
  description 'Sprinkle Provisioning Tool'
  gem 'sprinkle' do
    source 'http://gems.github.com' # use alternate gem server
    #repository '/opt/local/gems'   # specify an alternate local gem repository
  end
end


# Policies, sprinkle policy requires only the sprinkle gem

policy :sprinkle, :roles => :app do
  requires :sprinkle
end


# Deployment settings

deployment do

  # use vlad for deployment
  delivery :vlad do
    role :app, 'yourhost.com'
  end

end

# End of script, given the above information, Spinkle will apply the defined policy on all roles using the
# deployment settings specified.
