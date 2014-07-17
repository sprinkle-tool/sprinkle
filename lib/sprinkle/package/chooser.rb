module Sprinkle::Package
  class Chooser #:nodoc:

    def self.select_package(name, packages)
      if packages.size <= 1
        package = packages.first
      else
        package = choose do |menu|
          menu.prompt = "Multiple choices exist for virtual package #{name}"
          packages.each do |pkg|
            menu.choice(pkg.to_s) { pkg; }
          end
        end
      end
      cloud_info "Selecting #{package.to_s} for virtual package #{name}"
      package
    end

    def self.cloud_info(message)
      logger.info(message) if Sprinkle::OPTIONS[:cloud] or logger.debug?
    end

  end
end
