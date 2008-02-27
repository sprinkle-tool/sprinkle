require 'active_support'
require 'sprinkle/extensions/string'
require 'sprinkle/extensions/array'
require 'sprinkle/extensions/symbol'
require 'sprinkle/package'
require 'sprinkle/policy'
require 'sprinkle/deployment'
require 'sprinkle/installers/installer'
require 'sprinkle/installers/source'
require 'sprinkle/installers/apt'
require 'sprinkle/installers/gem'

class Object
  include Sprinkle
end

actor = ENV['DACTOR']

if actor
  # some other target?
else
  require 'sprinkle/actors/capistrano'
  
  # more work here
end