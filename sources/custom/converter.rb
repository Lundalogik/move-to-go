# encoding: UTF-8
require 'go_import'

# This Converter will convert a generic source to a XML file that can
# be imported into LIME Go.
#
# You MUST customzie this script to read a source and return a
# RootModel.
#
# Reference documentation for go_import can be found at
# https://rubygems.org/gems/go_import (click Documentation)
#
# Generate the xml-file that should be sent to LIME Go with the
# command:
# go-import run
#
# Good luck.

class Converter
    def to_go()
        rootmodel = GoImport::RootModel.new

        # *** TODO:
        #
        # Configure the model and then add coworkers, organizations, etc

        return rootmodel
    end
end
