# frozen_string_literal: true

$LOAD_PATH.append File.expand_path("../lib", __FILE__)
require "heracles/identity"

Gem::Specification.new do |spec|
  spec.name = Heracles::Identity.name
  spec.version = Heracles::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Paul Sadauskas"]
  spec.email = ["psadauskas@gmail.com"]
  spec.homepage = "https://github.com/paul/heracles"
  spec.summary = ""
  spec.license = "MIT"

  spec.required_ruby_version = "~> 2.5"

  spec.add_dependency "dry-core", "~> 0.4"
  spec.add_dependency "dry-types", "~> 0.12"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler-audit", "~> 0.6"
  spec.add_development_dependency "gemsmith", "~> 11.1"
  spec.add_development_dependency "git-cop", "~> 2.0"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-byebug", "~> 3.5"
  spec.add_development_dependency "pry-rescue"
  spec.add_development_dependency "pry-state", "~> 0.1"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "reek", "~> 4.7"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rspec-resembles_json_matchers"
  spec.add_development_dependency "rubocop", "~> 0.52"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
