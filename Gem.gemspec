$:.unshift(File.expand_path("../lib", __FILE__))
require "rspec/active_record_mocks/version"

Gem::Specification.new do |spec|
  spec.description = "Mock ActiveRecord tables to test concerns and other code."
  spec.files = %w(Readme.md License Rakefile Gemfile) + Dir.glob("lib/**/*")
  spec.homepage = "https://github.com/envygeeks/rspec-active_record_mocks"
  spec.summary = "Mock ActiveRecord tables to test."
  spec.version = RSpec::ActiveRecordMocks::VERSION
  spec.name = "rspec-active_record_mocks"
  spec.license = "Apache 2.0"
  spec.require_paths = ["lib"]
  spec.authors = "Jordon Bedwell"
  spec.email = "envygeeks@gmail.com"

  # --------------------------------------------------------------------------
  # Dependencies.
  # --------------------------------------------------------------------------

  spec.add_dependency("rspec", "~> 2.14")
  spec.add_dependency("activerecord", ">= 3.2", "<= 4.0")
end
