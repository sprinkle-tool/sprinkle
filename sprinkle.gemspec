require "./lib/sprinkle/version"

Gem::Specification.new do |s|
  s.name = "sprinkle"
  s.version = Sprinkle::Version

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcus Crafter", "Josh Goebel"]
  s.date = "2012-05-05"
  s.description = "Ruby DSL based software provisioning tool"
  s.email = "crafterm@redartisan.com"
  s.executables = ["sprinkle"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  s.homepage = "https://github.com/sprinkle-tool/sprinkle"
  s.require_paths = ["lib"]
  s.rubyforge_project = "sprinkle"
  s.rubygems_version = "1.8.15"
  s.summary = "Ruby DSL based software provisioning tool"

  s.add_development_dependency(%q<rspec>, [">= 2.5"])
  s.add_development_dependency(%q<rake>, [">= 0.8.7"])
  s.add_development_dependency(%q<rdoc>, [">= 3.12"])
  s.add_runtime_dependency(%q<open4>, [">= 1.1.0"])
  s.add_runtime_dependency(%q<activesupport>, [">= 2.0.2"])
  s.add_runtime_dependency(%q<highline>, [">= 1.4.0"])
  s.add_runtime_dependency(%q<capistrano>, [">= 2.5.5"])

end

