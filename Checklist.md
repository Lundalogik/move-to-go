# Import Checklist

## Pre import
- [ ] Check how many records will be imported. 10 000+ is considered large and might take more time
- [ ] Check what will be imported 
	- [ ] Organisations
	- [ ] Coworkers
	- [ ] Documents
	- [ ] Persons
	- [ ] Deals
	- [ ] Histories

- [ ] Check available consultant resources and schedule import date
- [ ] Check the source of the original data. We would like to access the data as untouched and raw as possible. It is possible to import through APIs or database dumps. We do prefer these over text-files

- [ ] Mapping of organization data: 
	- [ ] Name
	- [ ] Address (city, street)
	- [ ] Organisation number
	- [ ] Phone number
	- [ ] Email
	- [ ] Website
	- [ ] External ID
	- [ ] Discuss mapping of other data into tags and custom fields

- [ ] Mapping of deal data
	- [ ] External ID
	- [ ] Decide a deal process with appropriate statuses
	- [ ] Check IDs for coworkers, companies and histories
	- [ ] Discuss mapping of other data into tags and custom fields

- [ ] Mapping of coworker data
	- [ ] External ID
	- [ ] Email

- [ ] Mapping of person data
	- [ ] External ID
	- [ ] Email
	- [ ] Phone
	- [ ] First and last name
	- [ ] Company ID

- [ ] Mapping of history data
	- [ ] History text
	- [ ] Map categories to LIME Go categories (comment, talked to, sales call, did not reach)
	- [ ] Date
	- [ ] Company, coworker, person and/or deal ID

## During import

 - [ ] Make sure Ruby is installed (2.1, 64-bit) and all gems are updated
- [ ] Check if external IDs are imported correctly to LIME Go. This is very important to be able to rerun the import or add additional information at a later state
 - [ ] Never modify the source file. Do all modifications in code
- [ ] Create a product folder on a share volume so cooperation is possible
- [ ] Give development a heads up before a import is started on the server
- [ ] Do a test import on staging and give the customer access
- [ ] Formal acceptance from customer on test import
- [ ] Import on production

## Post import
- [ ] Turn of and delete the application from staging
- [ ] Can the source of the import be used as a template for other imports? 
- [ ] Improve documentation on GitHub
- [ ] Improve checklist on GitHub

