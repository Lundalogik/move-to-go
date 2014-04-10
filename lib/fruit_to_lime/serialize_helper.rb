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

        def self.serialize_variables_rexml(elem, obj)
            if (obj.respond_to?(:serialize_variables))
                obj.serialize_variables.each do |serialize_variable|
                    element_name = serialize_variable[:id].to_s.gsub(/^\@/,'').split('_').map do |m|
                        m.capitalize
                    end.join('')

                    raw_var = obj.instance_variable_get("@#{serialize_variable[:id].to_s}")
                    if raw_var != nil
                        element = elem.add_element(element_name)
                        if (raw_var.respond_to?(:serialize_variables))
                            SerializeHelper::serialize_variables_rexml(element, raw_var)
                        elsif (raw_var.is_a?(Array))
                            raw_var.each do |raw_var_elem| 
                                SerializeHelper::serialize_rexml(element, raw_var_elem) 
                            end
                        else
                            element.text = raw_var.to_s.encode('UTF-8')
                        end
                    end
                end
                return
            end
            raise "Do not know how to handle #{obj.class} !!"
        end

        def self.serialize_rexml(elem, obj)
            if obj.respond_to?(:to_rexml)
                obj.to_rexml(elem)
            elsif (obj.respond_to?(:serialize_variables))
                element_name = obj.serialize_name
                SerializeHelper::serialize_variables_rexml(elem.add_element(element_name), obj)
            else
                elem.text = obj.to_s
            end
        end

        def self.serialize(obj, indent= 2)
            # indent -1 to avoid indent
            if obj.respond_to?(:to_rexml)
                doc = REXML::Document.new()
                SerializeHelper::serialize_rexml(doc, obj)
                doc.write( xml_str = "" , indent, true)
                xml_str
            elsif (obj.respond_to?(:serialize_variables))
                element_name = obj.serialize_name
                doc = REXML::Document.new()
                SerializeHelper::serialize_variables_rexml(doc.add_element(element_name), obj)
                doc.write( xml_str = "", indent, true)
                xml_str
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
            when :custom_values then
                {
                    :id => p[:id].to_s,
                    :type => p[:type],
                    :name => symbol_to_name(p[:id]),
                    :models => SerializeHelper.get_import_rows(:custom_value)
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
            when :custom_value then
                CustomValue.new
            when :custom_field_reference then
                CustomFieldReference.new
            when :settings then
                Settings.new
            when :class_settings then
                ClassSettings.new
            else
                raise "Unknown type: #{type}"
            end.get_import_rows
        end
    end
end
