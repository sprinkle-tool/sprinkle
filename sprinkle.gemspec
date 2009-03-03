Gem::Specification.new do |s|
  s.name = %q{sprinkle}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcus Crafter", "Mitchell Hashimoto"]
  s.date = %q{2008-11-25}
  s.default_executable = %q{sprinkle}
  s.description = %q{Ruby DSL based software provisioning tool}
  s.email = ["crafterm@redartisan.com", "mitchell.hashimoto@citrusbyte.com"]
  s.executables = ["sprinkle"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["CREDITS", "History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "bin/sprinkle",
             "config/hoe.rb", "config/requirements.rb", "examples/packages/build_essential.rb", 
             "examples/packages/databases/mysql.rb", "examples/packages/databases/sqlite3.rb", 
             "examples/packages/phusion.rb", "examples/packages/ruby/rails.rb", "examples/packages/ruby/ruby.rb",
             "examples/packages/ruby/rubygems.rb", "examples/packages/scm/git.rb", "examples/packages/scm/subversion.rb",
             "examples/packages/servers/apache.rb", "examples/rails/README", "examples/rails/deploy.rb",
             "examples/rails/packages/database.rb", "examples/rails/packages/essential.rb", "examples/rails/packages/rails.rb",
             "examples/rails/packages/scm.rb", "examples/rails/packages/search.rb", "examples/rails/packages/server.rb",
             "examples/rails/rails.rb", "examples/sprinkle/sprinkle.rb", "lib/sprinkle.rb", "lib/sprinkle/actors/actors.rb",
             "lib/sprinkle/actors/capistrano.rb", "lib/sprinkle/actors/local.rb", "lib/sprinkle/actors/ssh.rb", "lib/sprinkle/actors/vlad.rb",
             "lib/sprinkle/configurable.rb", "lib/sprinkle/deployment.rb", "lib/sprinkle/extensions/arbitrary_options.rb",
             "lib/sprinkle/extensions/array.rb", "lib/sprinkle/extensions/blank_slate.rb", "lib/sprinkle/extensions/dsl_accessor.rb",
             "lib/sprinkle/extensions/string.rb", "lib/sprinkle/extensions/symbol.rb", "lib/sprinkle/installers/apt.rb",
             "lib/sprinkle/installers/deb.rb", "lib/sprinkle/installers/gem.rb", "lib/sprinkle/installers/installer.rb",
             "lib/sprinkle/installers/rake.rb", "lib/sprinkle/installers/rpm.rb", "lib/sprinkle/installers/source.rb",
             "lib/sprinkle/installers/yum.rb", "lib/sprinkle/installers/freebsd_pkg.rb", "lib/sprinkle/installers/openbsd_pkg.rb",
             "lib/sprinkle/installers/opensolaris_pkg.rb", "lib/sprinkle/installers/bsd_port.rb", "lib/sprinkle/installers/mac_port.rb", "lib/sprinkle/installers/push_text.rb", 
             "lib/sprinkle/package.rb", "lib/sprinkle/policy.rb", "lib/sprinkle/script.rb", "lib/sprinkle/verifiers/directory.rb", 
             "lib/sprinkle/verifiers/executable.rb", "lib/sprinkle/verifiers/file.rb", "lib/sprinkle/verifiers/process.rb", 
             "lib/sprinkle/verifiers/ruby.rb", "lib/sprinkle/verifiers/symlink.rb", "lib/sprinkle/verify.rb", "lib/sprinkle/version.rb",
             "script/destroy", "script/generate", "sprinkle.gemspec", "tasks/deployment.rake", "tasks/environment.rake", "tasks/rspec.rake"]
              
  s.test_files = ["spec/spec.opts", "spec/spec_helper.rb", "spec/sprinkle/actors/capistrano_spec.rb",
                  "spec/sprinkle/actors/local_spec.rb", "spec/sprinkle/configurable_spec.rb", "spec/sprinkle/deployment_spec.rb",
                  "spec/sprinkle/extensions/array_spec.rb", "spec/sprinkle/extensions/string_spec.rb", "spec/sprinkle/installers/apt_spec.rb",
                  "spec/sprinkle/installers/gem_spec.rb", "spec/sprinkle/installers/installer_spec.rb", "spec/sprinkle/installers/rpm_spec.rb",
                  "spec/sprinkle/installers/yum_spec.rb", "spec/sprinkle/installers/source_spec.rb", "spec/sprinkle/installers/freebsd_pkg_spec.rb",
                  "spec/sprinkle/installers/openbsd_pkg_spec.rb", "spec/sprinkle/installers/opensolaris_pkg_spec.rb",
                  "spec/sprinkle/installers/mac_port_spec.rb", "spec/sprinkle/installers/push_text_spec.rb", "spec/sprinkle/installers/bsd_port_spec.rb", "spec/sprinkle/policy_spec.rb",
                  "spec/sprinkle/script_spec.rb", "spec/sprinkle/sprinkle_spec.rb", "spec/sprinkle/installers/rake_spec.rb", "spec/sprinkle/verify_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://sprinkle.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sprinkle}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Ruby DSL based software provisioning tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<highline>, [">= 1.4.0"])
      s.add_runtime_dependency(%q<capistrano>, [">= 2.2.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
      s.add_development_dependency(%q<echoe>, [">= 3.0.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_dependency(%q<highline>, [">= 1.4.0"])
      s.add_dependency(%q<capistrano>, [">= 2.2.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.0.2"])
    s.add_dependency(%q<highline>, [">= 1.4.0"])
    s.add_dependency(%q<capistrano>, [">= 2.2.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
