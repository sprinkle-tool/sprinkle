module Sprinkle
  module Installers
    # = Source Package Installer
    #
    # The source package installer installs software from source.
    # It handles downloading, extracting, configuring, building,
    # and installing software.
    #
    # == Configuration Options
    #
    # The source installer has many configuration options:
    # * <b>prefix</b> - The prefix directory that is configured to.
    # * <b>archives</b> - The location all the files are downloaded to.
    # * <b>builds</b> - The directory the package is extracted to to configure and install
    #
    # == Pre/Post Hooks
    #
    # The source installer defines a myriad of new stages which can be hooked into:
    # * <b>prepare</b> - Prepare is the stage which all the prefix, archives, and build directories are made.
    # * <b>download</b> - Download is the stage which the software package is downloaded.
    # * <b>extract</b> - Extract is the stage which the software package is extracted.
    # * <b>configure</b> - Configure is the stage which the ./configure script is run.
    # * <b>build</b> - Build is the stage in which `make` is called.
    # * <b>install</b> - Install is the stage which `make install` is called.
    #
    # == Example Usage
    #
    # First, a simple package, no configuration:
    #
    #   package :magic_beans do
    #     source 'http://magicbeansland.com/latest-1.1.1.tar.gz'
    #   end
    #
    # Second, specifying exactly where I want my files:
    #
    #   package :magic_beans do
    #     source 'http://magicbeansland.com/latest-1.1.1.tar.gz' do
    #       prefix    '/usr/local'
    #       archives  '/tmp'
    #       builds    '/tmp/builds'
    #     end
    #   end
    #
    # Third, specifying some hooks:
    #
    #   package :magic_beans do
    #     source 'http://magicbeansland.com/latest-1.1.1.tar.gz' do
    #       prefix    '/usr/local'
    #
    #       pre :prepare { 'echo "Here we go folks."' }
    #       post :extract { 'echo "I believe..."' }
    #       pre :build { 'echo "Cross your fingers!"' }
    #     end
    #   end
    #
    # Fourth, specifying a custom archive name because the downloaded file name
    # differs from the source URL:
    #
    #   package :gitosis do
    #     source 'http://github.com/crafterm/sprinkle/tarball/master' do
    #       custom_archive 'crafterm-sprinkle-518e33c835986c03ec7ae8ea88c657443b006f28.tar.gz'
    #     end
    #   end
    #
    # Fifth, specifying a custom directory where the archive actually is extracted to:
    #
    #   package :ruby_build do
    #     source 'https://github.com/sstephenson/ruby-build/archive/v20130227.tar.gz' do
    #       custom_dir 'ruby-build-20130227'
    #       custom_install './install.sh'
    #     end
    #   end
    #
    # Sixth, specifying custom configure, build, and install commands:
    #
    #   package :mysql_build do
    #     source 'http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.25a.tar.gz/from/http://cdn.mysql.com/' do
    #       custom_archive 'mysql-5.5.25a.tar.gz'
    #       configure_command 'cmake .'
    #       build_command 'make'             # This is actually the default command but could be set to something else here.
    #       install_command 'make install'   # This is actually the default command but could be set to something else here.
    #     end
    #   end
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as
    # its parameter.

    class Source < Installer
      attr_accessor :source #:nodoc:
      
      api do
        def source(source, options = {}, &block)
          @recommends << :build_essential # Ubuntu/Debian
          install Source.new(self, source, options, &block)
        end
      end

      def initialize(parent, source, options = {}, &block) #:nodoc:
        super parent, options, &block
        @source = source
      end

      multi_attributes :enable, :disable, :with, :without, :option,
        :custom_install, :configure_command, :build_command, :install_command

      def install_sequence #:nodoc:
        prepare + download + extract + configure + build + install
      end

      protected

        %w( prepare download extract configure build install ).each do |stage|
          define_method stage do
            pre_commands(stage.to_sym) + self.send("#{stage}_commands") + post_commands(stage.to_sym)
          end
        end

        def prepare_commands #:nodoc:
          raise 'No installation area defined' unless @options[:prefix]
          raise 'No build area defined' unless @options[:builds]
          raise 'No source download area defined' unless @options[:archives]

          [ "mkdir -p #{@options[:prefix]}",
            "mkdir -p #{@options[:builds]}",
            "mkdir -p #{@options[:archives]}" ]
        end

        def download_commands #:nodoc:
          [ "wget -cq -O '#{@options[:archives]}/#{archive_name}' #{@source}" ]
        end

        def extract_commands #:nodoc:
          [ "bash -c 'cd #{@options[:builds]} && #{extract_command} #{@options[:archives]}/#{archive_name}'" ]
        end

        def configure_commands #:nodoc:
          return [] if custom_install?

          command = "bash -c 'cd #{build_dir} && #{actual_configure_command} --prefix=#{@options[:prefix]} "

          extras = {
            :enable  => '--enable', :disable => '--disable',
            :with    => '--with',   :without => '--without',
            :option  => '-',
          }

          extras.inject(command) { |m, (k, v)|  m << create_options(k, v) if options[k]; m }

          [ command << " > #{@package.name}-configure.log 2>&1'" ]
        end

        def build_commands #:nodoc:
          return [] if custom_install?
          [ "bash -c 'cd #{build_dir} && #{actual_build_command} > #{@package.name}-build.log 2>&1'" ]
        end

        def install_commands #:nodoc:
          return custom_install_commands if custom_install?
          [ "bash -c 'cd #{build_dir} && #{actual_install_command} > #{@package.name}-install.log 2>&1'" ]
        end

        def actual_configure_command #:nodoc:
          @options[:configure_command] || './configure'
        end

        def actual_build_command #:nodoc:
          @options[:build_command] || 'make'
        end

        def actual_install_command #:nodoc:
          @options[:install_command] || 'make install'
        end

        def custom_install? #:nodoc:
          !! @options[:custom_install]
        end

        # REVISIT: must be better processing of custom install commands somehow? use splat operator?
        def custom_install_commands #:nodoc:
          dress @options[:custom_install], nil, :install
        end

      protected
      
        def pre_commands(stage) #:nodoc:
          dress @pre[stage] || [], :pre, stage
        end

        def post_commands(stage) #:nodoc:
          dress @post[stage] || [], :post, stage
        end
      

        # dress is overriden from the base Sprinkle::Installers::Installer class so that the command changes
        # directory to the build directory first. Also, the result of the command is logged.
        def dress(commands, pre_or_post, stage)
          chdir = "cd #{build_dir} && "
          chdir = "" if [:prepare, :download].include?(stage)
          chdir = "" if stage == :extract and pre_or_post == :pre
          commands.collect { |command| "bash -c '#{chdir}#{command} >> #{@package.name}-#{stage}.log 2>&1'" }
        end

      private

        def create_options(key, prefix) #:nodoc:
          @options[key].inject('') { |m, option| m << "#{prefix}-#{option} "; m }
        end

        def extract_command #:nodoc:
          case archive_name
          when /(tar.gz)|(tgz)$/
            'tar xzf'
          when /(tar.bz2)|(tb2)$/
            'tar xjf'
          when /tar$/
            'tar xf'
          when /zip$/
            'unzip -o'
          else
            raise "Unknown source archive format: #{archive_name}"
          end
        end

        def archive_name #:nodoc:
          name = @source.split('/').last
          if options[:custom_archive]
            name = options[:custom_archive]
            name = name.join if name.is_a? Array
          end
          raise "Unable to determine archive name for source: #{source}, please update code knowledge" unless name
          name
        end

        def build_dir #:nodoc:
          "#{@options[:builds]}/#{options[:custom_dir] || base_dir}"
        end

        def base_dir #:nodoc:
          if archive_name.split('/').last =~ /(.*)\.(tar\.gz|tgz|tar\.bz2|tar|tb2|zip)/
            return $1
          end
          raise "Unknown base path for source archive: #{@source}, please update code knowledge"
        end

    end
  end
end
