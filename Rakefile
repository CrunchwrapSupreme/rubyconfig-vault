require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :docker do
  desc 'Build docker image'
  task :build do
    system('docker build . -t rconfvault:latest')
  end

  desc 'Run specs in docker container'
  task :spec do
    system('docker run --rm -t rconfvault:latest')
  end
end

task :default => :spec
