package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client libmysqlclient15-dev )
end

package :mysql_ruby_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql' # :build_flags => "—with-mysql-config=/usr/local/mysql/bin/mysql_config"
  
  verify do
    ruby_can_load 'mysql'
  end
end
