policy :sprinkle, :roles => :app do
  requires :sprinkle
end

package :sprinkle do
  i=runner "test" do
    # pre(:install) { install Installers::Runner.new(self,"before") }
    # pre(:install) { runner "pre" }
    # post(:install) { runner "after" }
    post(:install) { noop }
  end
  # puts runner("blah")
  # puts i.inspect
  runner "next"
end

deployment do

  # use vlad for deployment
  delivery :dummy do
    # role :app, 'yourhost.com'
  end

end
