module Sprinkle
  module Installers
    class Apt < Installer
      attr_accessor :packages

      def initialize(parent, *packages, &block)
        super parent, &block
        packages.flatten!
        
        options = { :dependencies_only => false }
        options.update(packages.pop) if packages.last.is_a?(Hash)
        
        @command = options[:dependencies_only] ? 'build-dep' : 'install'
        @packages = packages
      end

      protected

        def install_commands
          "DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get -qyu #{@command} #{@packages.join(' ')}"
        end

    end
  end
end
