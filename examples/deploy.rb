set :application, "asb"

# create a pseudo terminal for every command, otherwise SSH/SVN breaks
#default_run_options[:pty] = true 

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/path/to/sites/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
# set :user, "root"

role :app, "yourhost.com"
role :web, "yourhost.com"
role :db,  "yourhost.com", :primary => true
