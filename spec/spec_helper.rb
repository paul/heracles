# frozen_string_literal: true

require "bundler/setup"
require "pry"
require "pry-byebug"

require "awesome_print"
require "ostruct"

require "heracles"

require "active_support/core_ext/object/try.rb" # FIXME: put in resembles_json_matchers
require "rspec/resembles_json_matchers"
require "rspec/benchmark"

Dir[File.join(File.dirname(__FILE__), "support/shared_contexts/**/*.rb")].each do |file|
  require file
end

# Order matters
%w[
  blog_post_shield
  user_shield
].each do |fixture|
  require File.join(File.dirname(__FILE__), "fixtures", fixture)
end

RSpec.configure do |config|
  config.color = true
  config.order = "random"
  config.formatter = ENV["CI"] == "true" ? :progress : :documentation
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "./tmp/rspec-status.txt"
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  $stdout = File.new("/dev/null", "w") if ENV["SUPPRESS_STDOUT"] == "enabled"
  $stderr = File.new("/dev/null", "w") if ENV["SUPPRESS_STDERR"] == "enabled"
end
