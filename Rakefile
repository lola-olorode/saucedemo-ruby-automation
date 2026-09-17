require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb,api_tests/**/*_spec.rb"
end

task default: :spec

desc "Run only smoke-tagged specs (add `smoke: true` metadata to use this)"
RSpec::Core::RakeTask.new(:smoke) do |t|
  t.rspec_opts = "--tag smoke"
end

desc "Run only unit specs (framework logic, no browser)"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = "spec/unit/**/*_spec.rb"
end

desc "Run only the API test suite (no browser)"
RSpec::Core::RakeTask.new(:api) do |t|
  t.pattern = "api_tests/**/*_spec.rb"
end
