module Sprinkle
  module Installers
    # The gem package installer installs Ruby gems.
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
    # Third, specify the `gem` command:
    #
    #   package :magic_beans do
    #     gem 'magic_beans' do
    #       gem_command '/usr/bin/gem2.0'  # Or just `gem2.0`.
    #     end
    #   end
    #
    # There is an additional `gem2` installer:
    #
    #   package :magic_beans do
    #     gem2 'magic_beans'
    #   end
    #
    # This is a shortcut for `gem` using `gem2.0` as value of `gem_command`.
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as
    # its parameter.
    class Gem < Installer

      api do
        def gem(name, options = {}, &block)
          recommends :rubygems
          install Gem.new(self, name, options, &block)
        end
        def gem2(name, options = {}, &block)
          gem(name, options.merge(:gem_command => 'gem2.0'), &block)
        end
      end

      attr_accessor :gem #:nodoc:

      def initialize(parent, gem, options = {}, &block) #:nodoc:
        super parent, options, &block
        @gem = gem
      end

      attributes :gem_command, :source, :repository, :http_proxy, :build_flags, :version

      protected

        # rubygems 0.9.5+ installs dependencies by default, and does platform selection

        def install_commands #:nodoc:
          if option?(:gem_command)
            gem_cmd = gem_command
          else
            gem_cmd = 'gem'
          end
          cmd = "#{sudo_cmd}#{gem_cmd} install #{gem}"
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
