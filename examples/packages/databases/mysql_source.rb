# Install the latest MySQL database from source
package :mysql do
  requires :mysql_dependencies, :mysql_user_group, :mysql_user, :mysql_core
end

package :mysql_dependencies do
  description 'MySQL dependencies'
  apt 'cmake'
end

package :mysql_user_group do
  description 'MySQL user group'
  group 'mysql'
  verify do
    has_group 'mysql'
  end
end

package :mysql_user do
  description 'MySQL user'
  requires :mysql_user_group
  runner 'useradd -r -g mysql mysql'
  verify do
    has_user 'mysql'
  end
end

package :mysql_core do
  description 'MySQL database'
  version '5.5.25a'
  requires :mysql_dependencies, :mysql_user_group, :mysql_user
  source "http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-#{version}.tar.gz/from/http://cdn.mysql.com/" do
    custom_archive "mysql-#{version}.tar.gz"
    configure_command 'cmake .'
    post :install, '/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql'
    post :install, 'chown -R mysql:mysql /usr/local/mysql/data'
  end
  verify do
    has_executable '/usr/local/mysql/bin/mysql'
  end
end
