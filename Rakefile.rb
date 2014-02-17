#!/usr/bin/env rake
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks({:dir=>File.dirname(__FILE__),:name=>'fruit_to_lime'})