require 'spec_helper'
require 'tomodel'

describe 'Exporter' do
    before(:all) do
        exporter = Exporter.new
        organizations_file = File.join(File.dirname(__FILE__), 'sample_data', 'company.txt')
        @model = exporter.to_model(nil, organizations_file, nil, nil, nil, nil, nil)
    end
end
