# frozen_string_literal: true

guard :rspec, cmd: "bundle exec rspec --format documentation --tag ~type:performance" do
  watch(%r(^spec/.+_spec\.rb$))
  watch(%r(^lib/(.+)\.rb$)) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb") { "spec" }

  watch(%r(^lib/)) { "spec" }
end
