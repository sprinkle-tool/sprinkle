set :application, "application"

role :app, "yourhost.com"
role :web, "yourhost.com"
role :db,  "yourhost.com", :primary => true
