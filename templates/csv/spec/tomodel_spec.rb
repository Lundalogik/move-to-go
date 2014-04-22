require 'spec_helper'
require 'tomodel'

describe 'Exporter' do
    before(:all) do
        exporter = Exporter.new
        organizations_file =File.join(File.dirname(__FILE__), 'sample_data', 'organizations.csv')
        @model = exporter.to_model(organizations_file)        
    end
    it "will find something with a name" do
        organization = @model.organizations[0]
        organization.name.length.should > 0
    end
end
