# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nm/version"

Gem::Specification.new do |gem|
  gem.name        = "nm"
  gem.version     = Nm::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = %q{Node-Map: a data templating DSL.}
  gem.description = %q{Node-Map: a data templating DSL.}
  gem.homepage    = "http://github.com/redding/nm"
  gem.license     = "MIT"

  gem_files = `git ls-files`.split($/)
  gem_files -= gem_files.grep(%r{^(bench)/})
  gem_files -= gem_files.grep(%r{^(script)/})
  gem.files         = gem_files
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.5"

  gem.add_development_dependency("assert", ["~> 2.19.6"])
end
