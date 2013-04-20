package :sphinx, :provides => :search do
  description 'MySQL full text search engine'
  version '0.9.8.1'
  requires :mysql_dev
  
  source "http://www.sphinxsearch.com/downloads/sphinx-#{version}.tar.gz"
end

package :mysql_dev do
  description 'MySQL Database development package'
  
  apt %w( libmysqlclient15-dev )
end
