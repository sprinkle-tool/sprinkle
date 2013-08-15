require 'erubis'
require 'digest/md5'

module Sprinkle::Package
  module Rendering
    extend ActiveSupport::Concern

    included do
      self.send :include, Helpers
    end

    def template(src, context=binding)
      eruby = Erubis::Eruby.new(src)
      eruby.result(context)
    rescue Object => e
      raise Sprinkle::Errors::TemplateError.new(e, src, context)
    end
    
    def render(filename, context=binding)
      contents=File.read(expand_filename(filename))
      template(contents, context)
    end
    
    # Helper methods can be called from inside your package and 
    # verification code
    module Helpers
      # return the md5 of a string (as a hex string)
      def md5(s)
        Digest::MD5.hexdigest(s)
      end
    end
    
    private 
    
    def expand_filename(n) #:nodoc:
      return n.to_s if n.to_s.starts_with? "/"
      ["./templates/#{n}","./templates/#{n}.erb"].each do |f|
        return f if File.exist?(f)
      end
      raise "template file not found"
    end

  end
end
