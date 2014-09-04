#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'fileutils'
require 'tmpdir'
require './lib/go_import/templating.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'
#Bundler::GemHelper.install_tasks({:dir=>File.dirname(__FILE__),:name=>'go_import'})

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

task :clean_temporary_templates_folder do
    unpack_path = File.expand_path("unpacked", Dir.tmpdir)
    FileUtils.remove_dir(unpack_path, true)
    FileUtils.mkdir(unpack_path)
end

def execute_command_with_success_for_template(cmd, template)
    system(cmd)
    if ! $?.success?
        puts "Failed with #{$?}"
        raise "failed! #{cmd} for template #{template}"
    end
end

def unpack_template_and_run_specs(template)
    unpack_path = File.expand_path("unpacked", Dir.tmpdir)
    templating = FruitToLime::Templating.new('templates')
    templating.unpack template, unpack_path
    Dir.chdir(File.expand_path(template, unpack_path)) do
        execute_command_with_success_for_template('rake spec', template)
    end
end

desc "csv template spec"
task :csv_template_spec => [:clean_temporary_templates_folder] do
    unpack_template_and_run_specs 'csv'
end

desc "excel template spec"
task :excel_template_spec => [:clean_temporary_templates_folder] do
    unpack_template_and_run_specs 'excel'
end

desc "sqlserver template spec"
task :sqlserver_template_spec => [:clean_temporary_templates_folder] do
    unpack_template_and_run_specs 'sqlserver'
end

desc "specs for go_import and templates"
task :spec_and_templates => [:spec, :csv_template_spec, :excel_template_spec] do
end
