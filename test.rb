# package :echo do
#   runner "echo hello world"
# end
# 
# package :version do
#   runner "cat /etc/lsb-release"
# end
# 
# policy :once, :roles => :app do
#   requires :echo
#   requires :version
# end
# 
package :db do
  # go do
  #   puts "<eval db>"
  #   runner "installing the db"
  # end
  verify do
    has_file "/etc/db"
  end
  # runner "finalized"
end

package :hostname do
  # go do
  #   # puts "<eval hostname : #{hostname}>"
  #   runner "echo #{hostname} > /etc/hostname", :sudo => true
  # end
  # push_text "now", "/etc/stupid_file"
  # details "using name: front.pastie.org"
  
  # runner "echo 'hostname'"
  # runner "cat /etc/hostname"
  
  version "5"
  
  @what = "secret"
  @something = "else"
  file "/Users/jgoebel/notnow#{version}", :contents => c=render(:first)
  # transfer "<%= @what %>\n<%= @what + something %>", "/Users/jgoebel/notnow2", :render => true,
  # :binding => binding
  
  verify do
    has_file "/Users/jgoebel/notnow#{version}"
    # md5_of_file "/Users/jgoebel/notnow", md5(c)
  end
  # verify do
  #   has_executable "/bin/ccc"
  # end
end

package :web do
  requires :db
  
  # go do
  #   # puts "<eval web>"
  #   runner "installing web #{opts[:name]}"
  # end
  # runner "finalized"
  
  verify do
    # has_file "/etc/web/#{opts[:name]}"
  end
end

policy :twice, :roles => :app do
  requires :hostname
  # requires :db
  # requires :web, :name => "bob"
  # requires :web, :name => "suzy"
  # requires :web, :name => "nick"
end

deployment do
  
  # delivery :dummy do
  #   role :app, 'beta1.pastie.org'
  #   role :app, 'beta2.pastie.org'
  # end
  
  delivery :local
  
  # delivery :vlad do
  #   script "vlad"
  # end

  # use ssh for deployment
  # delivery :ssh do
  #   role :app, 'front.pastie.org'
  #   user "appz"
  # end
  
  # delivery :capistrano
  # delivery :capistrano do
  #   role :app, 'beta1.pastie.org'
    # role :app, 'beta2.pastie.org'
    # set :user, "appz"
    # set :use_sudo, true
  # end

end