#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:units) do |t|
    t.libs << "test"
    t.test_files = FileList['test/unit_test*.rb']
  end

  task :default do
    task(:units).execute
  end

end

task :default => 'test:units'
