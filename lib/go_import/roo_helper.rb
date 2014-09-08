require "csv"
module GoImport
    # @example transform xlsx file into rows
    #     organizations_path = File.join(File.dirname(__FILE__), 'organizations.xlsx') # same path as this file
    #     rows = GoImport::RooHelper.new(Roo::Excelx.new(organizations_path)).rows
    class RooHelper

        def initialize(data)
            @data = data
            @default_sheet = data.sheets.first
        end

        # Get rows for the first sheet.
        # The rows are hashes of the first row of cells as header cells and the rest as content.
        # @example If the header 'Name' and the second column contains 'Johan'.
        #    GoImport::RooHelper.new(Roo::Excelx.new(file_path)).rows
        #    # returns:
        #    [{'Name'=>'Johan'}]
        def rows
            return rows_for_sheet(@default_sheet)
        end

        # Returns true if the current workbook has a sheet with the
        # specifed name. This is case sensitive.
        def has_sheet?(name)
            sheet = @data.sheets.find { |s| s.to_s == name}

            return !sheet.nil?
        end

        # @example transform xlsx file into rows for the second sheet
        #     data = Roo::Excelx.new(organizations_path)
        #     rows = GoImport::RooHelper.new(data).rows_for_sheet(data.sheets[1])
        def rows_for_sheet(sheet)
            column_headers = {}
            1.upto(@data.last_column(sheet)) do |col|
                column_headers[col] = @data.cell(1, col, sheet).encode('UTF-8')
            end

            rs = []
            2.upto(@data.last_row(sheet)) do |row|
                r = {}
                1.upto(@data.last_column(sheet)) do |col|
                    val = cell_to_csv(row, col, sheet)
                    r[column_headers[col]] = val
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
                        onecell.encode('UTF-8').strip
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
