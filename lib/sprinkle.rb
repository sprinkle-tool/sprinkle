require 'rubygems'
require 'active_support/all'

# Use active supports auto load mechanism
require 'active_support/version'
if ActiveSupport::VERSION::MAJOR > 2
  require 'active_support/dependencies'
  ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)
else
  ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__)
end

# Configure active support to log auto-loading of dependencies
#ActiveSupport::Dependencies::RAILS_DEFAULT_LOGGER = Logger.new($stdout)
#ActiveSupport::Dependencies.log_activity = true

require File.dirname(__FILE__) + "/sprinkle/version.rb"

# Load up extensions to existing classes
Dir[File.dirname(__FILE__) + '/sprinkle/extensions/*.rb'].each { |e| require e }
# Load up the verifiers so they can register themselves
Dir[File.dirname(__FILE__) + '/sprinkle/verifiers/*.rb'].each { |e| require e }
# Load up the installers so they can register themselves
Dir[File.dirname(__FILE__) + '/sprinkle/installers/*.rb'].each { |e| require e }

# Configuration options
module Sprinkle
  OPTIONS = { :testing => false, :verbose => false, :force => false }
end

# Object is extended to Add the package and policy methods. To read about 
# each method, see the corresponding module which is included.
#--
# Define a logging target and understand packages, policies and deployment DSL
#++
class Object #:nodoc:
  include Sprinkle::Package, Sprinkle::Core

  def logger # :nodoc:
    # ActiveSupport::BufferedLogger was deprecated and replaced by ActiveSupport::Logger in Rails 4.
    # Use ActiveSupport::Logger if available.
    active_support_logger = defined?(ActiveSupport::Logger) ? ActiveSupport::Logger : ActiveSupport::BufferedLogger
    @@__log__ ||= active_support_logger.new($stdout, active_support_logger::Severity::INFO)
  end
end
