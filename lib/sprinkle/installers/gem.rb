module Sprinkle
  module Installers
    class Gem < Installer
      def initialize(parent, gem, &block)
        super parent, &block
        @gem = gem
      end
      
      protected
      
        # rubygems 0.9.5+ installs dependencies by default, and does platform selection
        # REVISIT: assume yes? how do we handle multiple versions? install version specified in the package if available
        
        def install_sequence
          unless version
            ["gem install #{@gem}"]
          else
            ["gem install #{@gem} --version #{version}"]
          end
        end
    end
  end
end
