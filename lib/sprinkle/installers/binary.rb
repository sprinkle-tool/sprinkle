module Sprinkle
  module Installers
    # The Binary installer will download a binary archive and then extract
    # it in the directory specified by the prefix option.
    # 
    # == Example Usage
    #
    #  binary "http://some.url.com/archive.tar.gz" do
    #    prefix   "/home/user/local"
    #    archives "/home/user/sources"
    #  end 
    # 
    # This example will download archive.tar.gz to /home/user/sources and then
    # extract it into /home/user/local.
    class Binary < Installer
      
      api do
        def binary(source, options = {}, &block)
          install Sprinkle::Installers::Binary.new(self, source, options, &block)
        end
      end
      
      def initialize(parent, binary_archive, options = {}, &block) #:nodoc:
        @binary_archive = binary_archive
        super parent, options, &block
      end

      def prepare_commands #:nodoc:
        raise 'No installation area defined' unless @options[:prefix]
        raise 'No archive download area defined' unless @options[:archives]

        [ "mkdir -p #{@options[:prefix].first}",
          "mkdir -p #{@options[:archives].first}" ]
      end

      def install_commands #:nodoc:
        commands = [ "bash -c 'wget -cq --directory-prefix=#{@options[:archives].first} #{@binary_archive}'" ]
        commands << "bash -c \"cd #{@options[:prefix].first} && #{extract_command} '#{@options[:archives].first}/#{archive_name}'\""
      end

      def archive_name #:nodoc:
        @archive_name ||= @binary_archive.split("/").last.gsub('%20', ' ')
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
          raise "Unknown binary archive format: #{archive_name}"
        end
      end
    end
  end
end
