# encoding: UTF-8

require 'go_import'
require 'roo'
require_relative("../converter")

def convert_source
    puts "Trying to convert Excel source to LIME Go..."

    converter = Converter.new

    # First we read each sheet from the excel file into separate
    # variables

    if defined?(EXCEL_FILE) && !EXCEL_FILE.empty?()
        if !::File.exists?(EXCEL_FILE)
            puts "ERROR: Cant find excel file to import: '#{EXCEL_FILE}'."
            raise
        end
    else
        puts "ERROR: You must set EXCEL_FILE in converter.rb to point to the excel file that should be imported."
        raise
    end

    excel_workbook = GoImport::ExcelHelper.Open(EXCEL_FILE)

    if defined?(COWORKER_SHEET)
        if excel_workbook.has_sheet?(COWORKER_SHEET)
            coworker_rows = excel_workbook.rows_for_sheet COWORKER_SHEET
        else
            puts "WARNING: can't find sheet '#{COWORKER_SHEET}'"
        end
    end

    if defined?(ORGANIZATION_SHEET)
        if excel_workbook.has_sheet?(ORGANIZATION_SHEET)
            organization_rows = excel_workbook.rows_for_sheet ORGANIZATION_SHEET
        else
            puts "WARNING: can't find sheet '#{ORGANIZATION_SHEET}'"
        end
    end

    if defined?(PERSON_SHEET)
        if excel_workbook.has_sheet?(PERSON_SHEET)
            person_rows = excel_workbook.rows_for_sheet PERSON_SHEET
        else
            puts "WARNING: can't find sheet '#{PERSON_SHEET}'"
        end
    end

    if defined?(DEAL_SHEET)
        if excel_workbook.has_sheet?(DEAL_SHEET)
            deal_rows = excel_workbook.rows_for_sheet DEAL_SHEET
        else
            puts "WARNING: can't find sheet '#{DEAL_SHEET}'"
        end
    end

    if defined?(NOTE_SHEET)
        if excel_workbook.has_sheet?(NOTE_SHEET)
            note_rows = excel_workbook.rows_for_sheet NOTE_SHEET
        else
            puts "WARNING: can't find sheet '#{NOTE_SHEET}'"
        end
    end

    if defined?(FILE_SHEET)
        if excel_workbook.has_sheet?(FILE_SHEET)
            file_rows = excel_workbook.rows_for_sheet FILE_SHEET
        else
            puts "WARNING: can't find sheet '#{FILE_SHEET}'"
        end
    end

    # Then we create a rootmodel that will contain all data that
    # should be exported to LIME Go.
    rootmodel = GoImport::RootModel.new

    # And configure the model if we have any custom fields
    converter.configure rootmodel

    # Now start to read data from the excel file and add to the
    # rootmodel. We begin with coworkers since they are referenced
    # from everywhere (orgs, deals, notes)
    if defined?(coworker_rows) && !coworker_rows.nil?
        puts "Trying to convert coworkers..."
        coworker_rows.each do |row|
            rootmodel.add_coworker(converter.to_coworker(row))
        end
    end

    # Then create organizations, they are only referenced by
    # coworkers.
    if defined?(organization_rows) && !organization_rows.nil?
        puts "Trying to convert organizations..."
        organization_rows.each do |row|
            organization = converter.to_organization(row, rootmodel)
            organization.set_tag "Import"
            rootmodel.add_organization(organization)
        end
    end

    # Add people and link them to their organizations
    if defined?(person_rows) && !person_rows.nil?
        puts "Trying to convert persons..."
        person_rows.each do |row|
            # People are special since they are not added directly to
            # the root model
            converter.import_person_to_organization(row, rootmodel)
        end
    end

    # Deals can connected to coworkers, organizations and people.
    if defined?(deal_rows) && !deal_rows.nil?
        puts "Trying to convert deals..."
        deal_rows.each do |row|
            rootmodel.add_deal(converter.to_deal(row, rootmodel))
        end
    end

    # Notes must be owned by a coworker and the be added to
    # organizations and notes and might refernce a person
    if defined?(note_rows) && !note_rows.nil?
        puts "Trying to convert notes..."
        note_rows.each do |row|
            rootmodel.add_note(converter.to_note(row, rootmodel))
        end
    end

    if defined?(file_rows) && !file_rows.nil?
        puts "Trying to convert files..."
        file_rows.each do |row|
            rootmodel.add_file(converter.to_file(row, rootmodel))
        end
    end

    return rootmodel
end

