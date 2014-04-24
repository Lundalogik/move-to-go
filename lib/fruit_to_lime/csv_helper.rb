require "csv"
module FruitToLime
    module CsvHelper
        def self.detect_col_sep(text)
            firstline = text.split('\n').first
            col_seps = [';','\t',',']
            return col_seps.find do |c|
                firstline.include? c
            end
        end
        
        def self.text_to_hashes(text, column_separator = nil)
            if !text
                raise "Missing text"
            end

            if !column_separator
                column_separator = self.detect_col_sep text
            end

            rows = CSV.parse(text.strip,{:col_sep => column_separator})
            map = {}
            first = rows.first 
            (0 .. first.length-1).each do |i|
                map[i] = first[i]
            end
            rs = []
            (1 .. rows.length-1).each do |i|
                r={}
                (0 .. map.length-1).each do |j|
                    r[map[j]] = rows[i][j]
                end
                rs.push(r)
            end
            return rs
        end
    end
end