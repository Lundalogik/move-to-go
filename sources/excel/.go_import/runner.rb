
require_relative("../converter")

def convert_source
    puts "Trying to convert Excel source to LIME Go..."

    converter = Converter.new
    model = converter.to_go

    return model
end

