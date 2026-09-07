require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run only smoke-tagged specs (add `smoke: true` metadata to use this)"
RSpec::Core::RakeTask.new(:smoke) do |t|
  t.rspec_opts = "--tag smoke"
end

desc "Run only unit specs (framework logic, no browser)"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = "spec/unit/**/*_spec.rb"
end
