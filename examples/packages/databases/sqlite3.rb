# Packages to install sqlite3 and the sqlite3 ruby driver.
package :sqlite3, :provides => :database do
  description 'SQLite3 database'
  apt 'sqlite3'
end

package :sqlite3_ruby_driver do
  description 'Ruby SQLite3 library.'
  apt 'libsqlite3-dev libsqlite3-ruby1.8'
  
  requires :rubygems
  
  verify do
    ruby_can_load 'sqlite3'
  end
end