require "fileutils"
require 'open3'
module GoImport
    class Templating
        def initialize(path)
            @path = path
        end

        def list()
            Dir.entries(@path).select { |d| d != '.' && d != '..' }
        end

        def unpack(name, path)
            template = list.find { |t| t == name }
            if template
                unpackedname = name

                puts "Unpacking template #{name} to #{path}"
                FileUtils.cp_r File.expand_path(name, @path), path

                # Now make sure all gems in template are installed
                puts "Making sure all needed gems are present"
                Dir.chdir(File.expand_path(unpackedname, path)) do
                    exec_but_dont_show_unless_error('bundle install --verbose')
                end
                true
            else
                puts "Unable to find template #{name}"
                false
            end
        end

        private
        def exec_but_dont_show_unless_error(cmd)
            std_out_value = []
            Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
                while std_line = stdout.gets
                    std_out_value << std_line
                end

                exit_status = wait_thr.value
                if !exit_status.success?
                    puts "Failed with #{exit_status}"
                    puts "std_out_value"
                    puts std_out_value

                    raise "failed exec #{cmd}"
                end
            end
        end
    end
end
