module Sprinkle
  # Deployment blocks specify deployment specific information about a 
  # sprinkle script. An example:
  #
  #   deployment do
  #     # mechanism for deployment
  #     delivery :capistrano do
  #       recipes 'deploy'
  #     end
  # 
  #     # source based package installer defaults
  #     source do
  #       prefix   '/usr/local'
  #       archives '/usr/local/sources'
  #       builds   '/usr/local/build'
  #     end
  #   end
  #
  # What the above example does is tell sprinkle that we will be using
  # *capistrano* (Sprinkle::Actors::Capistrano) for deployment and
  # everything within the block is capistrano specific configuration.
  # For more information on what options are available, check the corresponding
  # Sprinkle::Actors doc page.
  #
  # In addition to what delivery mechanism we're using, we specify some
  # configuration options for the "source" command. The only things
  # configurable, at this time, in the deployment block other than
  # the delivery method are installers. If installers are configurable,
  # they will say so on their corresponding documentation page. See
  # Sprinkle::Installers
  #
  # <b>Only one deployment block is on any given sprinkle script</b>
  module Deployment
    # The method outlined above which specifies deployment specific information
    # for a sprinkle script. For more information, read the header of this module.
    def deployment(&block)
      @deployment = Deployment.new(&block)
    end

    class Deployment
      attr_accessor :style, :defaults #:nodoc:

      def initialize(&block) #:nodoc:
        @defaults = {}
        self.instance_eval(&block)
        raise 'No delivery mechanism defined' unless @style
      end

      # Specifies which Sprinkle::Actors to use for delivery. Although all
      # actors jobs are the same: to run remote commands on a server, you
      # may have a personal preference. The block you pass is used to configure
      # the actor. For more information on what configuration options are
      # available, view the corresponding Sprinkle::Actors page.
      def delivery(type, &block) #:doc:
        @style = ("Sprinkle::Actors::" + type.to_s.titleize).constantize.new &block
      end

      def method_missing(sym, *args, &block) #:nodoc:
        @defaults[sym] = block
      end

      def respond_to?(sym) #:nodoc:
        !!@defaults[sym]
      end

      def process #:nodoc:
        POLICIES.each do |policy|
          policy.process(self)
        end
      end
    end
  end
end
