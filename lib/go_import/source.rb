require 'fileutils'
require 'open3'

module GoImport
    class Sources
        def initialize(path)
            @path = path
        end

        def list()
            Dir.entries(@path).select {
                |f| f != '.' && f != '..'
            }
        end

        def create_project_from_source(project_name, source_name)
            if !source_exists?(source_name)
                puts "The source '#{source_name}' doesnt exist."
                return false
            end

            if project_exists?(project_name)
                puts "A project named '#{project_name}' already exists"
                return false
            end

            begin
                copy_source_to_folder(source_name, project_name)

                install_gems_for_project(project_name)
                return true
            rescue
                puts "Something when wrong (errors should have been printed above)..."
                FileUtils.remove_dir(project_name, true)
                return false
            end
        end

        def about_source(source_name)
            if !source_exists?(source_name)
                puts "The source '#{source_name}' doesnt exist."
                return false
            end
            
            print_about_file_for_source(source_name)
        end

        private
        def print_about_file_for_source(name)
            about_path = ::File.expand_path("#{name}/.go_import/readme.txt", @path)

            if ::File.exists?(about_path)
                about_contents = ::File.open(about_path, "rb").read
                puts about_contents
            else
                puts "No about text specifed for source '#{name}'."
            end
        end
        
        private
        def source_exists?(name)
            source = list.find { |s| s.downcase == name.downcase }

            return !source.nil?
        end

        private
        def project_exists?(name)
            # do we have a folder named 'name' in the current folder?
            project = Dir.entries(Dir.pwd).find { |f| f.downcase == name.downcase}

            return !project.nil?
        end

        private
        def copy_source_to_folder(source_name, project_name)
            puts "Trying to create project '#{project_name}' from source '#{source_name}'..."
            FileUtils.cp_r ::File.expand_path(source_name, @path), project_name
        end

        private
        def install_gems_for_project(project_name)
            puts "Trying to verify that all required gems are installed..."
            Dir.chdir(::File.expand_path(project_name, Dir.pwd)) do
                exec_but_dont_show_unless_error('bundle install --verbose')
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
                    puts "Command '#{cmd}' failed with #{exit_status}"
                    puts "Output from command:"
                    puts std_out_value

                    raise "failed exec #{cmd}"
                end
            end
        end
    end
end
