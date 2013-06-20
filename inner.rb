policy :twice, :roles => :app do
  requires :hostname
  # requires :db
  # requires :web, :name => "bob"
  # requires :web, :name => "suzy"
  # requires :web, :name => "nick"
end

package :hostname do
  apt "test" do
    pre :install do
      runner "BEFORE"
      runner "BEFORE 2"
    end
    post :install do
      runner "AFTER" do
        pre(:install) { runner "before after" }
        post(:install) { runner "after after" }
      end
    end
  end
end

deployment do
  
  # delivery :dummy do
  #   role :app, 'beta1.pastie.org'
  #   role :app, 'beta2.pastie.org'
  # end

  # use vlad for deployment
  # delivery :ssh do
  #   role :app, 'beta1.pastie.org'
  #   user "appz"
  # end
  
  # delivery :capistrano
  delivery :capistrano do
    role :app, 'beta1.pastie.org'
    # role :app, 'beta2.pastie.org'
    set :user, "appz"
    set :use_sudo, true
  end

end