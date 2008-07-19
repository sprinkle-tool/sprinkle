module Sprinkle
  # = Programmatically Run Sprinkle
  #
  # Sprinkle::Script gives you a way to programatically run a given
  # sprinkle script. 
  class Script
    # Run a given sprinkle script. This method is <b>blocking</b> so
    # it will not return until the sprinkling is complete or fails.
    #--
    # FIXME: Improve documentation, possibly notify user how to tell
    # if a sprinkling failed.
    #++
    def self.sprinkle(script, filename = '__SCRIPT__')
      powder = new
      powder.instance_eval script, filename
      powder.sprinkle
    end

    def sprinkle #:nodoc:
      @deployment.process if @deployment
    end
  end
end
