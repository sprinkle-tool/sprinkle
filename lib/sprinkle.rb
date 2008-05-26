require 'rubygems'
require 'active_support'

# Use active supports auto load mechanism
Dependencies.load_paths << File.dirname(__FILE__)

# Configure active support to log auto-loading of dependencies
#Dependencies::RAILS_DEFAULT_LOGGER = Logger.new($stdout)
#Dependencies.log_activity = true

# Load up extensions to existing classes
Dir[File.dirname(__FILE__) + '/sprinkle/extensions/*.rb'].each { |e| require e }

# Configuration options
module Sprinkle
  OPTIONS = { :testing => false }
end

# Understand packages, policies and deployment DSL
class Object
  include Sprinkle::Package, Sprinkle::Policy, Sprinkle::Deployment
end

# Define a logging target
class Object
  def logger
    @@__log__ ||= ActiveSupport::BufferedLogger.new($stdout, ActiveSupport::BufferedLogger::Severity::INFO)
  end
end
