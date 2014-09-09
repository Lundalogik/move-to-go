#!/usr/bin/env rake
require 'rspec/core/rake_task'
#require 'fileutils'
#require 'tmpdir'
#require './lib/go_import/templating.rb'
#require './lib/go_import/source.rb'

task :spec do |t|
    system "rspec"
    if ! $?.success?
        puts "Failed: rspec with #{$?}"
        raise "failed!"
    end
end

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'

desc "Build gem"
task :build do
    # Forces update of bundle
    sh 'bundle update'
    Bundler::GemHelper.new().build_gem
end

desc "Installs gem locally"
task :install do
    Bundler::GemHelper.new().install_gem
end

desc "Releases gem to rubygems"
task :release do
    Bundler::GemHelper.new().release_gem
end

task :install_go_import do
    sh "bundle install"
end

require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

task :uninstall_go_import do
    ['go_import','fruit-to-lime'].each do |tool|
        begin
            Gem::GemRunner.new.run ['uninstall', tool, '-a', '-x']
        rescue Gem::SystemExitException => e
            puts e
        end
    end
end

desc "test go import gem"
task :test_go_import => [:uninstall_go_import, :install_go_import, :spec]

