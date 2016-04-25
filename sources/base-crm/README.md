# Base CRM migration

1. Export your Base CRM data with the built in export in Base CRM
2. Put the exported data into the `data` folder
3. Coworkers has to be entered manually into the coworkers file. A template file is provided
4. All mappings are done in `runner.rb` but special unique things can be configured in `converter.rb`

Note: In Base CRM you can have contacts persons without a corresponding organization.
This is not allowed in LIME Go and these persons and notes just linked to them will be ignored.   
