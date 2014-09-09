require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--tty --color -f documentation'
  task.verbose = false
end

task default: :spec

desc 'Pry console'
task :console do
  require 'active_tenant'
  require 'pry'
  ARGV.clear
  Pry.start
end