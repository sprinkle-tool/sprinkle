package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.2.0'
  source "http://rubyforge.org/frs/download.php/38646/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
    post :install, 'ln -s /usr/bin/gem1.8 /usr/bin/gem'
    post :install, 'gem update'
    post :install, 'gem update --system'
  end
  
  verify 'binary' do
    has_file '/usr/bin/gem1.8'
    has_symlink '/usr/bin/gem', '/usr/bin/gem1.8'
  end
  
  requires :ruby
end