$:.unshift(File.expand_path("../lib", __FILE__))
require "active_record_mocks/version"

Gem::Specification.new do |spec|
  spec.description = "Mock ActiveRecord tables to test concerns and other code."
  spec.files = %w(Readme.md License Rakefile Gemfile) + Dir.glob("lib/**/*")
  spec.homepage = "https://github.com/envygeeks/active_record_mocks"
  spec.summary = "Mock ActiveRecord tables to test."
  spec.version = ActiveRecordMocks::VERSION
  spec.name = "rspec-active_record_mocks"
  spec.email = "jordon@envygeeks.io"
  spec.license = "Apache 2.0"
  spec.require_paths = ["lib"]
  spec.authors = "Jordon Bedwell"

  spec.add_dependency("activerecord", ">= 3.2", "< 4.3")
  spec.add_development_dependency("envygeeks-coveralls", "~> 1.0")
  spec.add_development_dependency("luna-rspec-formatters", "~> 3.3")
  spec.add_development_dependency("rspec", "~> 3.3")
end
