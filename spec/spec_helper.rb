$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sprinkle'

module Sprinkle
  module TestLogger
    def logger
      # ActiveSupport::BufferedLogger was deprecated and replaced by ActiveSupport::Logger in Rails 4.
      # Use ActiveSupport::Logger if available.
      active_support_logger = defined?(ActiveSupport::Logger) ? ActiveSupport::Logger : ActiveSupport::BufferedLogger
      @@__log_file__ ||= StringIO.new
      @@__log__ = active_support_logger.new @@__log_file__, active_support_logger::Severity::INFO
    end
  end
end

class Object
  include Sprinkle::TestLogger
end
