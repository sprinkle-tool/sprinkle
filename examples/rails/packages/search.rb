package :sphinx, :provides => :search do
  description 'MySQL full text search engine'
  version '0.9.8.1'
  source "http://www.sphinxsearch.com/downloads/sphinx-#{version}.tar.gz"
  requires :mysql_dev
end

package :mysql_dev do
  description 'MySQL Database development package'
  apt %w( libmysqlclient15-dev )
end
