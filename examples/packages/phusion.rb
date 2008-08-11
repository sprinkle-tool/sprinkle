# Contains software created by Phusion.nl which is Ruby Enterprise Edition
# and mod_rails

package :ruby_enterprise do
  description 'Ruby Enterprise Edition'
  version '1.8.6-20080810'
  source 'http://rubyforge.org/frs/download.php/41040/ruby-enterprise-1.8.6-20080810.tar.gz' do
    custom_install 'echo -en "\n\n\n\n" | ./installer'
    
    # Modify the passenger conf file to point to REE
    post :install, 'sed -i "s|^PassengerRuby [/a-zA-Z0-9.]*$|PassengerRuby /opt/ruby-enterprise-1.8.6-20080810/bin/ruby|" /etc/apache2/extras/passenger.conf'
  
    # Restart apache
    post :install, '/etc/init.d/apache2 restart'
  end
  
  verify do
    has_directory '/opt/ruby-enterprise-1.8.6-20080810'
    has_executable '/opt/ruby-enterprise-1.8.6-20080810/bin/ruby'
  end
  
  requires :apache
  requires :passenger
end

package :passenger, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  gem 'passenger' do
    post :install, 'echo -en "\n\n\n\n" | passenger-install-apache2-module'
    
    # Create the passenger conf file
    post :install, 'mkdir /etc/apache2/extras'
    post :install, 'touch /etc/apache2/extras/passenger.conf'
    post :install, "echo 'Include /etc/apache2/extras/passenger.conf' >> /etc/apache2/apache2.conf"
    
    [%q(LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3/ext/apache2/mod_passenger.so),
    %q(PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3),
    %q(PassengerRuby /usr/bin/ruby1.8),
    %q(RailsEnv development)].each do |line|
      post :install, "echo '#{line}' >> /etc/apache2/extras/passenger.conf"
    end
    
    # Restart apache to note changes
    post :install, '/etc/init.d/apache2 restart'
  end
  
  verify do
    has_file '/etc/apache2/extras/passenger.conf'
    has_file '/usr/lib/ruby/gems/1.8/gems/passenger-2.0.3/ext/apache2/mod_passenger.so'
    has_directory '/usr/lib/ruby/gems/1.8/gems/passenger-2.0.3'
  end
  
  requires :apache
  requires :apache2_prefork_dev
end