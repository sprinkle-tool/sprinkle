package :ubuntu_version do
  runner "lsb_release -r"
end


policy :myapp, :roles => :app do
  requires :ubuntu_version
end

deployment do
  delivery :ssh do
    user 'root'
    password 'secret'
    role :app, 'server'
  end
end