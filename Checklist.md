# Migration Checklist (should be used before starting). 

- [ ] Check how many records will be migrated. 10 000+ is considered large and might take more time
- [ ] Check what will be migrated 
	- [ ] Organisations
	- [ ] Coworkers
	- [ ] Documents
	- [ ] Persons
	- [ ] Deals
	- [ ] Histories

- [ ] Check available consultant resources and schedule migration date
- [ ] Check the source of the original data. We would like to access the data as untouched and raw as possible. It is possible to migrate through APIs or database dumps. We do prefer these over text-files.

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
