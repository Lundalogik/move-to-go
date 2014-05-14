module FruitToLime
    # The ExcelHelper just makes it a little bit easier to open an
    # excel file in the imports. With ExcelHelper you don't need to
    # know anything about Roo and RooHelper.
    class ExcelHelper
        def self.Open(excel_filename)
            return RooHelper.new(Roo::Excelx.new(excel_filename))
        end
    end
end
