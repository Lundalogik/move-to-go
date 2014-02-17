require 'spec_helper'
require 'tomodel'

describe 'ToModel' do
    before(:all) do
        toModel = ToModel.new
        organizations_file =File.join(File.dirname(__FILE__), 'sample_data', 'organizations.csv')
        @model = toModel.to_model(organizations_file)        
    end
    it "will find something with a name" do
        organization = @model.organizations[0]
        organization.name.length.should > 0
    end
end
