# Move-to-go step by step.

##MIGRATION
1.	Go get Ruby... (should be 2.1.X, 64-bits).
2.	Open “Start Command Prompt with Ruby”.
3.	Enter this command `gem install move-to-go` to install or 'gem update move-to-go' to update.
4.	Wait.
5.	`Cd` (Change direction) to folder where you want to put the migration folder.
6.	Enter this command `move-to-go new MigrationFolder excel` (or other list-source).
7.	Now a folder named “MigrationFolder” is created.
8.	Enter the folder.
9.	Open up the ruby file “Converter.rb”, this is the place where you do the mapping of the fields. There you have a lot of comments with good help with the mapping. :).
10.	Now that you are done with your mapping. You enter the command `cd MigrationFolder`.

11.	Enter the command `move-to-go run`.
	a.	Now Ruby maps the source-file data with the converter file you edited. Wich results in a XML file that contains the fetched data and that Go can read.
12.	When it says “Source has been converted into ‘go_0.zip’.” You go ahead and log on to https://admin.staging.lime-go.com.
13.	Add a new application by clicking on one of the nice Nordic flags (Preferably the flag that belong to the country you represent).
14.	Enter a nice name and some info and click on “Submit”.
15.	Now you press the button “Add an account” which is the one you’ll use when you enter the staging account. 
16.	Under “Actions” you got some options, click on the link “Import data” to make a test migration. 
17.	Just upload the .zip file and wait until the job has been finished (may take a while).
18.	When the job is done, enter the account at https://go.staging.lime-go.com with the credentials you created in step 15.
19.	Check the data.
	a. Is it how it should be?
	b. Is there many "Failed to match" tags? If yes you might have a problem with the identifications.
	c. If you have imported any external IDs, check them so they are correct. It's important to be abel to rerun the migration or add additional inormation at a later state. 
20.	If yes, create an account (like at step 15) to the customer where they can look at the data aswell and give you a go to do the migration in the sharp environment. 

21.	When the customer has approved of the test-migration you need a account for https://admin.lime-go.com/ to being able to do the migration in the production environment.
22.	When you get in, search for an existing Application for the company. If it does, use it. 
23.	Do step 16-19 but now in the production environment. 
24. Remove the application (from step 13) and migration job (step 16) from https://admin.staging.lime-go.com.
25. Remove the migration job from https//admin.lime-go.com. DO NOT REMOVE THE APPLICATION.

#POST MIGRATION
26. Create a product folder for the migration on a share volume so cooperation is possible.
27. Can the source of the migration be used as a template for other migrations? 
28. Improve documentation on GitHub.
29. Improve checklist on GitHub.

##Questions? 
Easiest way to get in contact with the Lime Go development team is through the slack channel consultans.

