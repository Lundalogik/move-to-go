require "csv"
module FruitToLime
    class RooHelper
        def initialize(data)
            @data = data
            @sheet = data.sheets.first
            @map = {}
            1.upto(data.last_column(@sheet)) do |col|
               @map[col] = @data.cell(1, col, @sheet).encode('UTF-8')
            end
        end

        def rows
            rs = []
            2.upto(@data.last_row(@sheet)) do |row|
                r={}
                1.upto(@data.last_column(@sheet)) do |col|
                    val = cell_to_csv(row, col, @sheet)
                    r[@map[col]] = val
                end
                rs.push(r)
            end
            return rs
        end

        def cell_to_csv(row, col, sheet)
            if @data.empty?(row,col,sheet)
                ''
            else
                onecell = @data.cell(row,col,sheet)
                case @data.celltype(row,col,sheet)
                when :string
                    unless onecell.empty?
                        onecell.encode('UTF-8')
                    end
                when :float, :percentage
                    if onecell == onecell.to_i
                      onecell.to_i.to_s
                    else
                      onecell.to_s
                    end
                when :date, :datetime
                    onecell.to_s
                when :time
                    Roo::Base.integer_to_timestring(onecell)
                when :formula
                    onecell.to_s
                else
                    raise "unhandled celltype #{@data.celltype(row,col,sheet)} for cell at row: #{row}, col: #{col} in sheet #{sheet}"
                end || ""
            end
        end
    end
end
