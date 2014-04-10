require 'fileutils'
require 'tmpdir'

def execute_command_with_success_for_template(cmd, template)
	system(cmd)
	if ! $?.success?
		puts "Failed with #{$?}"
		raise "failed! #{cmd} for template #{template}"
	end
end

describe 'Templating' do
	let(:templating) { FruitToLime::Templating.new(File.expand_path("../templates", File.dirname(__FILE__))) }
	
	describe 'list' do
		it 'can find some templates' do
			templating.list().length.should > 0
		end
	end

	describe 'unpack' do
		unpack_path = File.expand_path("unpacked", Dir.tmpdir)
		before {
			FileUtils.remove_dir(unpack_path, true)
			FileUtils.mkdir(unpack_path)
		}

		it 'can unpack all templates and run the template tests' do
			templating.list().each {|t|
				templating.unpack t, unpack_path
				Dir.chdir(File.expand_path(t, unpack_path)) do
					execute_command_with_success_for_template('rake spec', t)
				end
			}
		end

		after {
			FileUtils.remove_dir(unpack_path, true)
		}
	end
end