require 'rubygems'
require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:config_spec) do | task |
  task.pattern = 'spec/config/*_spec.rb'
end

task default: [:spec]
