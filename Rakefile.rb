#!/usr/bin/env rake
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks({:dir=>File.dirname(__FILE__),:name=>'fruit_to_lime'})


task :install_fruit_to_lime do
    sh "bundle install"
end

require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

task :uninstall_fruit_to_lime do
    ['fruit_to_lime','fruit-to-lime'].each do |tool|
        begin
            Gem::GemRunner.new.run ['uninstall', tool, '-a', '-x']
        rescue Gem::SystemExitException => e
            puts e
        end
    end
end

desc "test fruit to lime gem"
task :test_fruit_to_lime => [:uninstall_fruit_to_lime, :install_fruit_to_lime, :spec] 

