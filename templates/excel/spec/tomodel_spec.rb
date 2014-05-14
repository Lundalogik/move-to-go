# Encoding: utf-8

require 'spec_helper'
require 'tomodel'

describe 'Model' do
    before(:all) do
        converter = Converter.new
        samplefile = File.join(File.dirname(__FILE__), '..', 'template.xlsx')
        @rootmodel = converter.to_model(samplefile)
    end

    it "will find something with a name" do
        organization = @rootmodel.organizations[0]
        organization.name.length.should > 0
    end
end

