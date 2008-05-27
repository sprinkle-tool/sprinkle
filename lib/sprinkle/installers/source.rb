module Sprinkle
  module Installers
    class Source < Installer
      attr_accessor :source, :pre, :post

      def initialize(parent, source, options = {}, &block)
        @pre = {}; @post = {}
        @source = source
        super parent, options, &block
      end

      def pre(stage, *commands)
        @pre[stage] ||= []
        @pre[stage] += commands
      end

      def post(stage, *commands)
        @post[stage] ||= []
        @post[stage] += commands
      end

      protected

        def install_sequence
          prepare + download + extract + configure + build + install
        end

        %w( prepare download extract configure build install ).each do |stage|
          define_method stage do
            pre_commands(stage.to_sym) + self.send("#{stage}_commands") + post_commands(stage.to_sym)
          end
        end

        def prepare_commands
          raise 'No installation area defined' unless @options[:prefix]
          raise 'No build area defined' unless @options[:builds]
          raise 'No source download area defined' unless @options[:archives]

          [ "mkdir -p #{@options[:prefix]}",
            "mkdir -p #{@options[:builds]}",
            "mkdir -p #{@options[:archives]}" ]
        end

        def download_commands
          [ "wget -cq --directory-prefix='#{@options[:archives]}' #{@source}" ]
        end

        def extract_commands
          [ "bash -c 'cd #{@options[:builds]} && #{extract_command} #{@options[:archives]}/#{archive_name}'" ]
        end

        def configure_commands
          return [] if custom_install?

          command = "bash -c 'cd #{build_dir} && ./configure --prefix=#{@options[:prefix]} "

          extras = {
            :enable  => '--enable', :disable => '--disable',
            :with    => '--with',   :without => '--without'
          }

          extras.inject(command) { |m, (k, v)| m << create_options(k, v) if options[k]; m }

          [ command << " > #{@package.name}-configure.log 2>&1'" ]
        end

        def build_commands
          return [] if custom_install?
          [ "bash -c 'cd #{build_dir} && make > #{@package.name}-build.log 2>&1'" ]
        end

        def install_commands
          return custom_install_commands if custom_install?
          [ "bash -c 'cd #{build_dir} && make install > #{@package.name}-install.log 2>&1'" ]
        end

        def custom_install?
          !! @options[:custom_install]
        end

        # REVISIT: must be better processing of custom install commands somehow? use splat operator?
        def custom_install_commands
          dress @options[:custom_install], :install
        end

      private

        def pre_commands(stage)
          dress @pre[stage] || [], :pre
        end

        def post_commands(stage)
          dress @post[stage] || [], :post
        end

        def dress(commands, stage)
          commands.collect { |command| "bash -c 'cd #{build_dir} && #{command} >> #{@package.name}-#{stage}.log 2>&1'" }
        end

        def create_options(key, prefix)
          @options[key].inject(' ') { |m, option| m << "#{prefix}-#{option} "; m }
        end

        def extract_command
          case @source
          when /(tar.gz)|(tgz)$/
            'tar xzf'
          when /(tar.bz2)|(tb2)$/
            'tar xjf'
          when /tar$/
            'tar xf'
          when /zip$/
            'unzip'
          else
            raise "Unknown source archive format: #{archive_name}"
          end
        end

        def archive_name
          name = @source.split('/').last
          raise "Unable to determine archive name for source: #{source}, please update code knowledge" unless name
          name
        end

        def build_dir
          "#{@options[:builds]}/#{base_dir}"
        end

        def base_dir
          if @source.split('/').last =~ /(.*)\.(tar\.gz|tgz|tar\.bz2|tb2)/
            return $1
          end
          raise "Unknown base path for source archive: #{@source}, please update code knowledge"
        end
    end
  end
end
