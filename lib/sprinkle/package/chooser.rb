module Sprinkle::Package
  class Chooser
    def self.select_package(name, packages)
      if packages.size <= 1
        package = packages.first
      else
        package = choose do |menu|
          menu.prompt = "Multiple choices exist for virtual package #{name}"
          menu.choices *packages.collect(&:to_s)
        end
        package = Sprinkle::Package::PACKAGES.first(package)
      end

      cloud_info "Selecting #{package.to_s} for virtual package #{name}"

      package
    end
    
    def self.cloud_info(message)
      logger.info(message) if Sprinkle::OPTIONS[:cloud] or logger.debug?
    end
    
  end
end