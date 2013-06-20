module Sprinkle
  # = Deployments
  #
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
  # The deployment block must be included in the script file passed to the 
  # sprinkle executable.  It may not be loaded from a required file unless you 
  # first manually include the Sprinkle::Deployment module in the Object class.
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
        type=type.to_s.titleize
        type="SSH" if type=="Ssh"
        @style = ("Sprinkle::Actors::" + type).constantize.new &block
      end

      def method_missing(sym, *args, &block) #:nodoc:
        @defaults[sym] = block
      end

      def respond_to?(sym) #:nodoc:
        !!@defaults[sym]
      end
      
      def active_policies #:nodoc:
        if role=Sprinkle::OPTIONS[:only_role]
          role=role.to_sym
          POLICIES.select {|x| [x.roles].flatten.include?(role) }
        else
          POLICIES
        end
      end

      def process #:nodoc:
        active_policies.each do |policy|
          policy.process(self)
        end
      rescue Sprinkle::Errors::RemoteCommandFailure => e
        e.print_summary
        exit 1
      rescue Sprinkle::Errors::TransferFailure => e
        e.print_summary
        exit 2
      ensure
        # do any cleanup our actor may need to close network sockets, etc
        @style.teardown if @style.respond_to?(:teardown)        
      end
    end
  end
end
