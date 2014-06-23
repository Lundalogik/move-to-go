require "csv"
module FruitToLime
    module CsvHelper

        # @example Detect column separator and transform to hashes
        #     hashes = FruitToLime::CsvHelper.text_to_hashes(text)
        #
        # @example Use specific column separator and transform to hashes
        #     column_separator = ','
        #     hashes = FruitToLime::CsvHelper.text_to_hashes(text, column_separator)
        def self.text_to_hashes(text, column_separator = nil, row_separator = :auto, quote_char = '"')
            if !text
                raise "Missing text"
            end

            if !column_separator
                column_separator = self.detect_col_sep text
            end

            rows = CSV.parse(text.strip,{:col_sep => column_separator, 
                :row_sep => row_separator, :quote_char => quote_char})
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
        
        private
        def self.detect_col_sep(text)
            firstline = text.split('\n').first
            col_seps = [';','\t',',']
            return col_seps.find do |c|
                firstline.include? c
            end
        end

    end
end