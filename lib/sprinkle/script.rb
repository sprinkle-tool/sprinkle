module Sprinkle
  class Script
    include Package, Policy, Deployment  # understand packages, policies and deployment DSL
    
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

