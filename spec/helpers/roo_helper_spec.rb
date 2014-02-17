require 'spec_helper'
require 'fruit_to_lime'
require 'roo'
describe FruitToLime::RooHelper do
	it "should handle sv chars" do
		samplefile = File.join(File.dirname(__FILE__), '..', 'sample_data', 'excel.xlsx')
		rows = FruitToLime::RooHelper.new(Roo::Excelx.new(samplefile)).rows
		rows.should include({"Alpha"=>"L\u00E5s","Beta"=>"m\u00E4sk","\u00D6rjan"=>"l\u00E4sk","\u00C4skil"=>""})
	end
end
