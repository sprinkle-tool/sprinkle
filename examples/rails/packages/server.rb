package :mongrel do
  description 'Mongrel Application Server'
  version '1.1.5'
  
  gem 'mongrel'
end

package :mongrel_cluster, :provides => :appserver do
  description 'Cluster Management for Mongrel'
  version '1.0.5'
  requires :mongrel
  
  gem 'mongrel_cluster'
end

package :apache, :provides => :webserver do
  description 'Apache 2 HTTP Server'
  version '2.2.11'
  requires :apache_dependencies
  
  source "http://www.apache.org/dist/httpd/httpd-#{version}.tar.bz2" do
    enable %w( mods-shared=all proxy proxy-balancer proxy-http rewrite cache headers ssl deflate so )
    prefix "/opt/local/apache2-#{version}"
    post :install, 'install -m 755 support/apachectl /etc/init.d/apache2', 'update-rc.d -f apache2 defaults'
  end
end

package :apache_dependencies do
  description 'Apache 2 HTTP Server Build Dependencies'
  
  apt %w( openssl libtool mawk zlib1g-dev libssl-dev )
end
