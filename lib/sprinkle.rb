require 'rubygems'
require 'logger'
require 'active_support'

# Use active supports auto load mechanism
Dependencies.load_paths << File.dirname(__FILE__)

# Configure active support to log auto-loading of dependencies
#Dependencies::RAILS_DEFAULT_LOGGER = Logger.new($stdout)
#Dependencies.log_activity = true

# Load up extensions to existing classes
Dir[File.dirname(__FILE__) + '/sprinkle/extensions/*.rb'].each { |e| require e }

# Define a global logger thats available everywhere
class Object
  def log
    @@__log__ ||= Logger.new($stdout)
  end
end

module Sprinkle
  OPTIONS = { :testing => false }
end
