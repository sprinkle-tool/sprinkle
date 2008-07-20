package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client libmysqlclient15-dev )
end

package :mysql_ruby_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'
  
  verify do
    ruby_can_load 'mysql'
  end
end