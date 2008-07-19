Gem::Specification.new do |s|
  s.name = %q{sprinkle}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcus Crafter", "Mitchell Hashimoto"]
  s.date = %q{2008-07-19}
  s.default_executable = %q{sprinkle}
  s.description = %q{Ruby DSL based software provisioning tool}
  s.email = ["crafterm@redartisan.com", "mitchell.hashimoto@citrusbyte.com"]
  s.executables = ["sprinkle"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["CREDITS", "History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "bin/sprinkle", "config/hoe.rb", "config/requirements.rb", "examples/merb/deploy.rb", "examples/rails/README", "examples/rails/deploy.rb", "examples/rails/packages/database.rb", "examples/rails/packages/essential.rb", "examples/rails/packages/rails.rb", "examples/rails/packages/search.rb", "examples/rails/packages/server.rb", "examples/rails/rails.rb", "examples/sprinkle/sprinkle.rb", "lib/sprinkle.rb", "lib/sprinkle/actors/actors.rb", "lib/sprinkle/actors/capistrano.rb", "lib/sprinkle/actors/vlad.rb", "lib/sprinkle/configurable.rb", "lib/sprinkle/deployment.rb", "lib/sprinkle/extensions/arbitrary_options.rb", "lib/sprinkle/extensions/array.rb", "lib/sprinkle/extensions/blank_slate.rb", "lib/sprinkle/extensions/dsl_accessor.rb", "lib/sprinkle/extensions/string.rb", "lib/sprinkle/extensions/symbol.rb", "lib/sprinkle/installers/apt.rb", "lib/sprinkle/installers/gem.rb", "lib/sprinkle/installers/installer.rb", "lib/sprinkle/installers/rake.rb", "lib/sprinkle/installers/rpm.rb", "lib/sprinkle/installers/source.rb", "lib/sprinkle/package.rb", "lib/sprinkle/policy.rb", "lib/sprinkle/script.rb", "lib/sprinkle/verifiers/directory.rb", "lib/sprinkle/verifiers/executable.rb", "lib/sprinkle/verifiers/file.rb", "lib/sprinkle/verifiers/process.rb", "lib/sprinkle/verifiers/symlink.rb", "lib/sprinkle/verify.rb", "lib/sprinkle/version.rb", "script/destroy", "script/generate", "spec/spec.opts", "spec/spec_helper.rb", "spec/sprinkle/actors/capistrano_spec.rb", "spec/sprinkle/configurable_spec.rb", "spec/sprinkle/deployment_spec.rb", "spec/sprinkle/extensions/array_spec.rb", "spec/sprinkle/extensions/string_spec.rb", "spec/sprinkle/installers/apt_spec.rb", "spec/sprinkle/installers/gem_spec.rb", "spec/sprinkle/installers/installer_spec.rb", "spec/sprinkle/installers/rpm_spec.rb", "spec/sprinkle/installers/source_spec.rb", "spec/sprinkle/package_spec.rb", "spec/sprinkle/policy_spec.rb", "spec/sprinkle/script_spec.rb", "spec/sprinkle/sprinkle_spec.rb", "spec/sprinkle/verify_spec.rb", "sprinkle.gemspec", "tasks/deployment.rake", "tasks/environment.rake", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://sprinkle.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sprinkle}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ruby DSL based software provisioning tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<highline>, [">= 1.4.0"])
      s.add_runtime_dependency(%q<capistrano>, [">= 2.2.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_dependency(%q<highline>, [">= 1.4.0"])
      s.add_dependency(%q<capistrano>, [">= 2.2.0"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.0.2"])
    s.add_dependency(%q<highline>, [">= 1.4.0"])
    s.add_dependency(%q<capistrano>, [">= 2.2.0"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
