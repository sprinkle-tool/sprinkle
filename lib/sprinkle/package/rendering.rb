require 'pp'
require 'erubis'
require 'digest/md5'

module Sprinkle::Package
  # For help on rendering, see the Sprinkle::Installers::FileInstaller.
  module Rendering
    extend ActiveSupport::Concern

    included do
      self.send :include, Helpers
    end

    # render src as ERB
    def template(src, context=binding)
      eruby = Erubis::Eruby.new(src)
      eruby.result(context)
    rescue Object => e
      raise Sprinkle::Errors::TemplateError.new(e, src, context)
    end

    # read in filename and render it as ERB
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
    
    # sets the path a package should use to search for templates
    def template_search_path(path)
      @template_search_path = path
    end

    private

    def search_paths(n) #:nodoc:
      # if we are given an absolute path, return just that path
      return [File.dirname(n)] if n.starts_with? "/"
      
      pwd = Dir.pwd
      package_dir = @template_search_path

      p = []
      # if ./ is used assume the path is relative to the package
      if package_dir
        p << File.expand_path(File.join(package_dir,"templates"))
        p << File.expand_path(package_dir)
      else
        # otherwise search template folders relate to cwd
        p << File.expand_path(File.join(pwd,"templates"))
        p << File.expand_path(pwd)
      end

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
