require 'rubygems'
require 'active_support/all'

if ActiveSupport::VERSION::MAJOR > 2
  require 'active_support/dependencies'
  ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)
else
  ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__)
end

# Configure active support to log auto-loading of dependencies
#ActiveSupport::Dependencies::RAILS_DEFAULT_LOGGER = Logger.new($stdout)
#ActiveSupport::Dependencies.log_activity = true

def require_all(*args)
  args.each { |f|
    Dir[File.dirname(__FILE__) + "/sprinkle/#{f}"].each { |e| require e } }
end

require_all "version.rb", "extensions/*.rb", "verifiers/*.rb", "installers/*.rb"

module Sprinkle
  # Configuration options
  OPTIONS = { :testing => false, :verbose => false, :force => false }
end

# Object is extended with a few helper methods.  Please see Sprinkle::Core.
#--
# Define a logging target and understand packages, policies and deployment DSL
#++
class Object
  include Sprinkle::Package, Sprinkle::Core

  def logger # :nodoc:
    # ActiveSupport::BufferedLogger was deprecated and replaced by ActiveSupport::Logger in Rails 4.
    # Use ActiveSupport::Logger if available.
    active_support_logger = defined?(ActiveSupport::Logger) ? ActiveSupport::Logger : ActiveSupport::BufferedLogger
    @@__log__ ||= active_support_logger.new($stdout, active_support_logger::Severity::INFO)
  end
end
