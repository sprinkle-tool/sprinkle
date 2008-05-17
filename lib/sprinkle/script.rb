module Sprinkle
  class Script
    def self.sprinkle(script, filename = '__SCRIPT__')
      powder = new
      powder.instance_eval script, filename
      powder.sprinkle
    end

    def sprinkle
      @deployment.process if @deployment
    end
  end
end
