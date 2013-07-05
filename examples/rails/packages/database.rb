package :mysql, :provides => :database do
  description 'MySQL Database'
  
  defaults :innodb_file_per_table => true,
    :innodb_buffer_pool_size => "512MB"
    
  file "/etc/my.cnf", 
    :contents => render("xmysql.cnf"),
    :sudo => true
  
  apt %w( mysql-server mysql-client )
end

package :ruby_mysql_driver do
  description 'Ruby MySQL database driver'
  requires :mysql
  
  gem 'mysql2'
end
