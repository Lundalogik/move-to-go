# encoding: utf-8
require "rexml/document"

module FruitToLime
    module SerializeHelper
        def serialize()
            SerializeHelper::serialize(self)
        end

        def serialize_to_file(file)
            SerializeHelper::serialize_to_file(file, self)
        end

        def self.serialize_variables(obj)
            if (obj.respond_to?(:serialize_variables))
                return obj.serialize_variables.map do |serialize_variable|
                    element_name = serialize_variable[:id].to_s.gsub(/^\@/,'').split('_').map do |m|
                        m.capitalize
                    end.join('')

                    varv = obj.instance_variable_get("@#{serialize_variable[:id].to_s}")
                    if (varv.respond_to?(:serialize_variables))
                        varv = serialize_variables(varv)
                    elsif (varv.is_a?(Array))
                        varv = varv.map { |elem| SerializeHelper::serialize(elem) }.join("\n")
                    elsif (varv == nil)
                        varv = nil
                    else
                        varv = varv.to_s.encode('UTF-8').encode(:xml => :text)
                    end
                    if varv != nil then "<#{element_name}>#{ varv }</#{element_name}>" else "" end
                    if varv != nil then "<#{element_name}>#{ varv }</#{element_name}>" end
                end.join("\n")
            end
            raise "!!#{obj.class}"
        end

        def self.serialize(obj)
            if (obj.respond_to?(:serialize_variables))
                element_name = obj.serialize_name
                doc = REXML::Document.new( "<#{element_name}>#{ SerializeHelper::serialize_variables(obj) }</#{element_name}>" )
                doc.write( targetstr = "", 2 ) #indents with 2 spaces
                targetstr
            elsif obj.respond_to?(:to_xml)
                obj.to_xml
            else
                obj.to_s.encode(:xml => :text)
            end
        end

        def self.serialize_to_file(file, obj)
            File.open(file, 'w') do |f|
                f.write(SerializeHelper::serialize(obj))
            end
        end

        def symbol_to_name(symbol)
            symbol.to_s.split('_').join(' ').capitalize
        end

        def map_symbol_to_row(symbol,type)
            {
                :id => symbol.to_s,
                :name => symbol == :id ? 'Go id' : symbol_to_name(symbol),
                :type =>type
            }
        end

        def map_to_row(p)
            case p[:type]
            when :string then
                map_symbol_to_row(p[:id],p[:type])
            when :bool then
                map_symbol_to_row(p[:id],p[:type])
            when :date then
                map_symbol_to_row(p[:id],p[:type])
            when :notes then
                {
                    :id => p[:id].to_s,
                    :name => symbol_to_name(p[:id]),
                    :type => p[:type],
                    :models => SerializeHelper.get_import_rows(:note)
                }
            when :tags then
                {
                    :id => p[:id].to_s,
                    :type => p[:type],
                    :name => symbol_to_name(p[:id]),
                }
            when :persons then
                {
                    :id => p[:id].to_s,
                    :type => p[:type],
                    :name => symbol_to_name(p[:id]),
                    :models => SerializeHelper.get_import_rows(:person)
                }
            when :custom_fields then
                {
                    :id => p[:id].to_s,
                    :type => p[:type],
                    :name => symbol_to_name(p[:id]),
                    :models => SerializeHelper.get_import_rows(:custom_field)
                }
            else
                {
                    :id => p[:id].to_s,
                    :name => symbol_to_name(p[:id]),
                    :type => p[:type],
                    :model => SerializeHelper.get_import_rows(p[:type])
                }
            end
        end

        def get_import_rows
            serialize_variables.map do |p|
                map_to_row p
            end
        end

        def self.get_import_rows(type)
            case type
            when :person then
                Person.new
            when :source_ref then
                ReferenceToSource.new
            when :note then
                Note.new
            when :address then
                Address.new
            when :organization then
                Organization.new
            when :coworker_reference then
                CoworkerReference.new
            when :organization_reference then
                OrganizationReference.new
            when :custom_field then
                CustomField.new
            else
                raise "Unknown type: #{type}"
            end.get_import_rows
        end
    end
end
