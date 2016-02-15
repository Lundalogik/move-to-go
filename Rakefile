require "bundler/gem_tasks"

task :spec do |t|
    system "rspec"
    if ! $?.success?
        puts "Failed: rspec with #{$?}"
        raise "failed!"
    end
end
