#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'albacore'

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

namespace :ms do
    $nuget = File.join(File.dirname(__FILE__),'nuget')

    desc "build using msbuild"
    msbuild :build do |msb|
        msb.properties :configuration => :Debug
        msb.targets :Clean, :Rebuild
        msb.verbosity = 'quiet'
        msb.solution = File.join('.', 'src', "FruitToLime.sln")
    end

    task :copy_to_nuspec => [:build] do
        output_directory_lib = File.join($nuget,"lib/40/")
        mkdir_p output_directory_lib
        cp Dir.glob(File.join('.', 'src', "FruitToLime/bin/Debug/FruitToLime.dll")), output_directory_lib
    end

    task :nugetpack => [:copy_to_nuspec] do |nuget|
        cd File.join($nuget) do
          sh "..\\src\\.nuget\\NuGet.exe pack FruitToLime.nuspec"
        end
    end
end