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
    system('docker run --rm -t rconfvault:latest bundle exec rake')
  end

  desc 'Run bin/console inside docker container'
  task :console do
    system('docker run --rm -it rconfvault:latest bundle exec bin/console')
  end
end

task :default => :spec
