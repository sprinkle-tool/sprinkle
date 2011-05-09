$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sprinkle'

module Kernel
  def logger
    @@__log_file__ ||= StringIO.new
    @@__log__ = ActiveSupport::BufferedLogger.new @@__log_file__
  end
end
