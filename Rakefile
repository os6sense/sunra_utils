require 'rubygems'
require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'

ENV['CODECLIMATE_REPO_TOKEN'] = '182c06e2d105a16e07c55f21415ba889770645df7835856b020265690507b2e1'
RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:config_spec) do | task |
  task.pattern = 'spec/config/*_spec.rb'
end

task default: [:spec]
