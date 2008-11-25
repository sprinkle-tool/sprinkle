module Sprinkle
  module Installers
    # = Ruby Gem Package Installer
    #
    # The gem package installer installs ruby gems.
    #
    # The installer has a single optional configuration: source.
    # By changing source you can specify a given ruby gems
    # repository from which to install.
    # 
    # == Example Usage
    #
    # First, a simple installation of the magic_beans gem:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     gem 'magic_beans'
    #   end
    #
    # Second, install magic_beans gem from github:
    #
    #   package :magic_beans do
    #     gem 'magic_beans_package' do
    #       source 'http://gems.github.com'
    #     end
    #   end
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as 
    # its parameter.
    class Gem < Installer
      attr_accessor :gem #:nodoc:

      def initialize(parent, gem, options = {}, &block) #:nodoc:
        super parent, options, &block
        @gem = gem
      end

      def source(location = nil) #:nodoc:
        # package defines an installer called source so here we specify a method directly
        # rather than rely on the automatic options processing since packages' method missing
        # won't be run
        return @options[:source] unless location
        @options[:source] = location
      end

      protected

        # rubygems 0.9.5+ installs dependencies by default, and does platform selection

        def install_commands #:nodoc:
          cmd = "gem install #{gem}"
          cmd << " --version '#{version}'" if version
          cmd << " --source #{source}" if source
          cmd << " --install-dir #{repository}" if option?(:repository)
          cmd << " --no-rdoc --no-ri" unless option?(:build_docs)
          cmd
        end
        
    end
  end
end
