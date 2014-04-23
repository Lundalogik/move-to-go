#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'fileutils'
require 'tmpdir'
require './lib/fruit_to_lime/templating.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

require 'bundler/gem_helper'
#Bundler::GemHelper.install_tasks({:dir=>File.dirname(__FILE__),:name=>'fruit_to_lime'})

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

desc "specs for fruit_to_lime and templates"
task :spec_and_templates => [:spec, :csv_template_spec, :excel_template_spec] do
end
