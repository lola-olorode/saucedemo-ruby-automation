require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run only smoke-tagged specs (add `smoke: true` metadata to use this)"
RSpec::Core::RakeTask.new(:smoke) do |t|
  t.rspec_opts = "--tag smoke"
end
