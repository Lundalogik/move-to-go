# encoding: UTF-8

require 'move-to-go'
#require 'roo'
require 'dbf'
require_relative("../converter")

KUND_FILE = './database/KUND.DBF'
KONTAKT_FILE = './database/KONTAKT.DBF'

def convert_source
    puts "Trying to convert VISMA Administration 2000 source to LIME Go..."

    # Verify that required files exists.
    if !File.exists?(KUND_FILE)
        puts "You MUST put KUND.DBF in the database folder."
        raise
    end

    if !File.exists?(KONTAKT_FILE)
        puts "You MUST put KONTAKT.DBF in the database folder."
        raise
    end

    puts "Trying to read data from VISMA files..."
    organization_rows = DBF::Table.new(KUND_FILE)
    person_rows = DBF::Table.new(KONTAKT_FILE)

    rootmodel = MoveToGo::RootModel.new
    converter = Converter.new

    converter.configure rootmodel

    # Then create organizations, they are only referenced by
    # coworkers.
    puts "Trying to process Organization..."
    organization_rows.each do |row|
        if not row.nil?
            if not row["NAMN"] == ""
                organization = converter.to_organization(row, rootmodel)
                rootmodel.add_organization(organization)
                converter.organization_hook(row, organization, rootmodel) if defined? converter.organization_hook
            end
        end
    end
    puts "Processed #{rootmodel.organizations.length} Organizations."

    # Add people and link them to their organizations
    puts "Trying to process Persons..."
    imported_person_count = 0
    person_rows.each do |row|
        # People are special since they are not added directly to
        # the root model
        if not row.nil?
            if not row["KUNDNR"] == "" and not row["NAMN"] == ""
                converter.import_person_to_organization(row, rootmodel)
                imported_person_count = imported_person_count + 1
            end
        end
    end
    puts "Processed #{imported_person_count} Persons."

    # History must be owned by a coworker and then should reference
    # organization or deal and might reference a person
    puts "Trying to process History..."
    imported_history_count = 0
    organization_rows.each do |row|
        if not row.nil?
            if row['ANTECK_1'].length > 0

                comment = MoveToGo::Comment.new()

                organization = rootmodel.find_organization_by_integration_id(row['KUNDNR'])
                unless organization.nil?
                    comment.organization = organization
                end
                comment.created_by = rootmodel.import_coworker
                comment.text = row['ANTECK_1']
                
                rootmodel.add_history(comment)
                imported_history_count = imported_history_count + 1
            end
        end
    end
    puts "Processed #{imported_history_count} History."

    return rootmodel
end

