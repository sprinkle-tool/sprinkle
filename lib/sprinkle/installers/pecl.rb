module Sprinkle
  module Installers
    # = Pecl extension installed
    #
    # Installs the specified pecl extension
    #
    # == Example Usage
    #
    #   package :php_stuff do
    #     pecl 'mongo'
    #     verify { has_pecl 'mongo' }
    #   end
    #
    # You can optionally pass a version number to both `pecl` and `has_pecl`:
    #
    #   package :php_stuff do
    #     pecl 'mongo', :version => "1.4.3"
    #     verify { has_pecl 'mongo', :version => "1.4.3" }
    #   end
    #
    # Some extensions need an ini file. You can have that generated, by passing the `:ini_file` option:
    #
    #   package :php_stuff do
    #     pecl 'mongo', :ini_file => true
    #   end
    #
    # If you need more fine grained control of the location or contents of the ini file, use:
    #
    #   package :php_stuff do
    #     pecl 'mongo', :ini_file => { :path => "/etc/php5/apache2/php.ini",
    #                                  :content => "extension=mongo.so",
    #                                  :sudo => true }
    #   end
    #
    class Pecl < Installer
      attr_accessor :package_name, :package_version

      api do
        def pecl(package_name, options = {}, &block)
          install Pecl.new(self, package_name, options, &block)
        end
      end

      verify_api do
        def has_pecl(package_name, options = {})
          @commands = "TERM= pecl list | grep '^#{package_name}\\\\s*" + (options[:version] ? options[:version].to_s : "") + "'"
        end
      end

      def initialize(parent, package_name, options = {}, &block) #:nodoc:
        super parent, &block
        @package_name = package_name
        @package_version = options[:version]
        @ini_file = options[:ini_file]
        setup_ini if @ini_file
      end
      
      def setup_ini
        @ini_file = to_ini_file_hash(@ini_file)
        text = @ini_file[:content] || "extension=#{@package_name}.so"
        path = @ini_file[:path] || "/etc/php5/conf.d/#{@package_name}.ini"
        use_sudo = @ini_file[:sudo]===false ? false : true
        post(:install) do
          file(path, :content => text, :sudo => use_sudo)
        end
      end
      
      def to_ini_file_hash(s)
        return {:content => s} if s.is_a? String
        return {} if s===true
        s
      end

      protected
        def install_commands #:nodoc:
          cmd = "TERM= pecl install --alldeps #{@package_name}"
          cmd << "-#{@package_version}" if @package_version
          cmd
        end
    end
  end
end
