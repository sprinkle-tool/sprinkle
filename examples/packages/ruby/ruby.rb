package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  apt %q(ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8 libreadline-ruby1.8 libruby1.8 libopenssl-ruby) do
    post :install, [%q(ln -s /usr/bin/ruby1.8 /usr/bin/ruby),
    %q(ln -s /usr/bin/ri1.8 /usr/bin/ri),
    %q(ln -s /usr/bin/rdoc1.8 /usr/bin/rdoc),
    %q(ln -s /usr/bin/irb1.8 /usr/bin/irb)]
  end
  
  verify 'binaries' do
    has_file '/usr/bin/ruby1.8'
    has_file '/usr/bin/ri1.8'
    has_file '/usr/bin/rdoc1.8'
    has_file '/usr/bin/irb1.8'
  end
end