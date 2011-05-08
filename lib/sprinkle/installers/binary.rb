module Sprinkle
  module Installers
    # = Binary Installer
    # 
    # binary "http://some.url.com/archive.tar.gz" do
    #  prefix   "/home/user/local"
    #  archives "/home/user/sources"
    # end 
    #
    class Binary < Installer
      def initialize(parent, binary_archive, options = {}, &block) #:nodoc:
        @binary_archive = binary_archive
        @options = options
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
        commands << "bash -c 'cd #{@options[:prefix].first} && #{extract_command} #{@options[:archives].first}/#{@binary_archive.split("/").last}'"
      end

      def extract_command(archive_name = @binary_archive.split("/").last)
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
