# coding: iso-8859-1
require 'spec_helper'
require 'move-to-go'

describe MoveToGo::CsvHelper do
    it "should" do
        v = MoveToGo::CsvHelper.text_to_hashes("id;navn
1;Noerrebro")
        v.should include({"id"=>"1","navn"=>"Noerrebro"})
    end
    it "should handle sv chars" do
        v = MoveToGo::CsvHelper.text_to_hashes("id;navn
1;Bj\u{00F6}rk")
        v.should include({"id"=>"1","navn"=>"Bj\u{00F6}rk"})
    end
    it "should handle escaped newlines" do
        v = MoveToGo::CsvHelper.text_to_hashes("id;navn
1;\"Bj\u{00F6}rk
And a new line\"")
        v.should include({"id"=>"1","navn"=>"Bj\u{00F6}rk
And a new line"})
    end
    it "should handle escaped newlines with ',' as delim" do
        v = MoveToGo::CsvHelper.text_to_hashes("id,navn
1,\"Bj\u{00F6}rk
And a new line\"")
        v.should include({"id"=>"1","navn"=>"Bj\u{00F6}rk
And a new line"})
    end

    it "should handled values with ," do
        # given
        str = "id,name,text
1,lundalogik,\"hej, hopp\""

        # when
        v = MoveToGo::CsvHelper.text_to_hashes(str)

        # then
        v.should include({
                             "id" => "1",
                             "name" => "lundalogik",
                             "text" => "hej, hopp"})
    end
end
