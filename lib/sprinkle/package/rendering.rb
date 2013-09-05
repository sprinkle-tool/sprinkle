require 'pp'
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
    
    def template_search_path(path)
      @template_search_path = path
    end

    private

    def search_paths(n)
      # if we are given an absolute path, return just that path
      return [File.dirname(n)] if n.starts_with? "/"
      
      dir = Dir.pwd
      package_dir = @template_search_path

      # if ./ is used assume the path is relative to the package
      if n.starts_with? "./"
        raise "must call template_search_path to use local references" unless @template_search_path
        return [File.expand_path(package_dir), 
          File.expand_path(File.join(package_dir,"templates"))] 
      end

      p = []
      # otherwise search template folders
      p << File.expand_path(File.join(dir,"templates"))
      p << File.expand_path(dir)
      p.uniq
    end

    def expand_filename(n) #:nodoc:
      name = File.basename(n)
      paths = search_paths(n).map do |p|
        [File.join(p,name), File.join(p,"#{name}.erb")]
      end.flatten

      paths.each do |f|
        return f if File.exist?(f)
      end

      puts "RESOLVED SEARCH PATHS"
      pp paths

      raise "template not found: #{n}"

    end

  end
end
