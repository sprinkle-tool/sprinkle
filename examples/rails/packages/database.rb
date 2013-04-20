package :mysql, :provides => :database do
  description 'MySQL Database'
  
  apt %w( mysql-server mysql-client )
end

package :ruby_mysql_driver do
  description 'Ruby MySQL database driver'
  requires :mysql
  
  gem 'mysql2'
end
