require "bundler/gem_tasks"

task :default => [:spec]

task :spec do |t|
    system "rspec"
    if ! $?.success?
        puts "Failed: rspec with #{$?}"
        raise "failed!"
    end
end
