require 'tempfile'

module Sprinkle
  module Installers
    class Fetch < Installer
      
      api do
        def fetch(uri, opts={}, &block)
          recommends :wget
          Fetch.new(self, uri, opts, &block)
        end
      end
      
      def initialize(parent, uri, options={}, &block)
        super parent, options, &block
        @source = uri
      end
      
      def install_commands
        [download_commands, extract_commands].compact
      end
      
      # public API that we expose for the benefit of source installer
      def download_commands
        "wget -cq -O '#{download_to}' #{@source}"
      end
      
      # public API that we expose for the benefit of source installer
      def extract_commands
        "bash -c 'cd #{extract_to} && #{extract_command} #{download_to}'"
      end
      
      def download_to #:nodoc:
        options[:download_to] || "#{options[:archives]}/#{archive_name}"
      end
      
      def extract_to #:nodoc:
        options[:extract_to] || options[:builds]
      end
      
      def archive_name #:nodoc:
        options[:archive_name] || File.basename(@source)
      end
      
      def extract_command #:nodoc:
        case @source
        when /(tar.gz)|(tgz)$/
          'tar xzf'
        when /(tar.bz2)|(tb2)$/
          'tar xjf'
        when /tar$/
          'tar xf'
        when /zip$/
          'unzip -o'
        else
          raise "Unknown source archive format: #{@source}"
        end
      end
      
    end
  end
end