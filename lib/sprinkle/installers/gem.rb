module Sprinkle
  module Installers
    class Gem < Installer
      attr_accessor :gem

      def initialize(parent, gem, &block)
        super parent, &block
        @gem = gem
      end

      protected

        # rubygems 0.9.5+ installs dependencies by default, and does platform selection

        def install_sequence
          unless version
            "gem install #{@gem}"
          else
            "gem install #{@gem} --version '#{version}'"
          end
        end
    end
  end
end
