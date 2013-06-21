require 'erubis'
require 'digest/md5'

module Sprinkle::Package
  module Rendering
    extend ActiveSupport::Concern

    included do
      self.send :include, Helpers
    end

    def template(src, context={})
      context.reverse_merge!(opts)
      eruby = Erubis::Eruby.new(src)
      output = eruby.evaluate(context)
    rescue Object => e
      raise Sprinkle::Errors::TemplateError.new(e, src, context)
    end

    def render(file, context={})
      contents=File.read(expand_filename(file))
      template(contents, context)
    end

    module Helpers
      def md5(s)
        Digest::MD5.hexdigest(s)
      end
    end

    private

    def expand_filename(n)
      return n.to_s if n.to_s.starts_with? "/"
      ["./templates/#{n}","./templates/#{n}.erb"].each do |f|
        return f if File.exist?(f)
      end
      raise "template file not found"
    end

  end
end