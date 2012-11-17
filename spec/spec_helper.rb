$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sprinkle'

class Object
  def logger
    unless defined?(@@__log__) && @@__log__
      @@__log_file__ = StringIO.new
      @@__log__ = ActiveSupport::BufferedLogger.new @@__log_file__
      @@__log__.level = ActiveSupport::BufferedLogger::Severity::INFO
    end
    @@__log__
  end
end
