module Sprinkle::Package
  class PackageRepository
    
    # sets up an empty repository
    def initialize
      clear
    end
    
    def clear
      @packages = []
    end
    
    # adds a single package to the repository
    def add(package)
      @packages << package
    end
    def <<(package); add(package); end
    
    # returns the first package matching the name and options given
    def first(name, opts={})
      find_all(name, opts).try(:first)
    end
    
    # returns all packages matching the name and options given (including via provides)
    def find_all(name, opts={})
      # opts ||= {}
      all = [@packages.select {|x| x.name.to_s == name.to_s },
      find_all_by_provides(name, opts)].flatten.compact
      filter(all, opts)
    end
            
    def count
      @packages.size
    end
    
  private
  
    def find_all_by_provides(name, opts={})
      @packages.select {|x| x.provides and x.provides.to_s == name.to_s }
    end
    
    def filter(all, opts)
      all = all.select {|x| "#{x.version}" == opts[:version].to_s} if opts[:version]
      all
    end
  
  end
end