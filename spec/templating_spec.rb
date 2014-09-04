require 'fileutils'
require 'tmpdir'

describe 'Templating' do
    let(:templating) { GoImport::Templating.new(File.expand_path("../templates", File.dirname(__FILE__))) }
    
    describe 'list' do
        it 'can find some templates' do
            templating.list().length.should > 0
        end
    end
end