$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sprinkle'

class Object
  def logger
    @@__log_file__ ||= StringIO.new
    @@__log__ = ActiveSupport::BufferedLogger.new @@__log_file__, ActiveSupport::BufferedLogger::Severity::INFO
  end
end
