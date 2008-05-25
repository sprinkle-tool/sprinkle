module Sprinkle
  module Installers
    class Gem < Installer
      attr_accessor :gem

      def initialize(parent, gem, options = {}, &block)
        super parent, options, &block
        @gem = gem
      end

      def source(location = nil)
        # package defines an installer called source so here we specify a method directly
        # rather than rely on the automatic options processing since packages' method missing
        # won't be run
        return @options[:source] unless location
        @options[:source] = location
      end

      protected

        # rubygems 0.9.5+ installs dependencies by default, and does platform selection

        def install_sequence
          cmd = "gem install #{gem}"
          cmd << " --version '#{version}'" if version
          cmd << " --source #{source}" if source
          cmd
        end
    end
  end
end
