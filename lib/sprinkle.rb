require 'rubygems'
require 'logger'
require 'active_support'

Dependencies.load_paths << File.dirname(__FILE__)

# Configure active support to log auto-loading of dependencies
#Dependencies::RAILS_DEFAULT_LOGGER = Logger.new($stdout)
#Dependencies.log_activity = true

# Define a global logger thats available everywhere
class Object
  def log
    @@__log__ ||= Logger.new($stdout)
  end
end

module Sprinkle
end
