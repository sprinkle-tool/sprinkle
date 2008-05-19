package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client )
end

package :mysql_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'
end
