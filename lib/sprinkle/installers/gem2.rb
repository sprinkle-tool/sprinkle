module Sprinkle
  module Installers
    # Same as gem installer except it uses `gem2.0`.
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
    #     gem2 'magic_beans'
    #   end
    #
    # Second, install magic_beans gem from github:
    #
    #   package :magic_beans do
    #     gem2 'magic_beans_package' do
    #       source 'http://gems.github.com'
    #     end
    #   end
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as
    # its parameter.
    class Gem2 < Installer

      api do
        def gem2(name, options = {}, &block)
          recommends :rubygems
          install Gem2.new(self, name, options, &block)
        end
      end

      attr_accessor :gem #:nodoc:

      def initialize(parent, gem, options = {}, &block) #:nodoc:
        super parent, options, &block
        @gem = gem
      end

      attributes :source, :repository, :http_proxy, :build_flags, :version
      # FIXME Why is ':build_docs' not included?

      protected

        # rubygems 0.9.5+ installs dependencies by default, and does platform selection

        def install_commands #:nodoc:
          cmd = "#{sudo_cmd}gem2.0 install #{gem}"
          cmd << " --version '#{version}'" if version
          cmd << " --source #{source}" if source
          cmd << " --install-dir #{repository}" if option?(:repository)
          cmd << " --no-rdoc --no-ri" unless option?(:build_docs)
          cmd << " --http-proxy #{http_proxy}" if option?(:http_proxy)
          cmd << " -- #{build_flags}" if option?(:build_flags)
          cmd
        end

    end
  end
end
