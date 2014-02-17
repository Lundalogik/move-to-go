# Encoding: utf-8

require 'spec_helper'
require 'tomodel'


describe 'Model' do
    before(:all) do
        toModel = ToModel.new
        samplefile =File.join(File.dirname(__FILE__), 'sample_data', 'sample.xlsx')
        @model = toModel.to_model(samplefile)        
    end
    it "will find something with a name" do
        organization = @model.organizations[0]
        organization.name.length.should > 0
    end    
end

