module Sprinkle
  module Installers
    class Gem < Installer
      attr_accessor :gem

      def initialize(parent, gem, options = {}, &block)
        super parent, options, &block
        @gem = gem
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
