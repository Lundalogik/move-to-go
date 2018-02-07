# Move-to-go step by step.

1. Go get Ruby... (should be 2.4.1, 64-bits at https://rubyinstaller.org/downloads/).
2. When installing, tick in the checkboxes to install toolkit and add Ruby executables to your PATH.
3. Open "Start Command Prompt with Ruby".
4. Enter this command `gem install move-to-go` to install or 'gem update move-to-go' to update.
5. Wait...
6. `cd` (Change direction) to folder where you want to put the migration folder.
7. Enter this command `move-to-go new MigrationFolder excel` (or other list-source).
8. Now a folder named “MigrationFolder” is created.
9. Enter the folder.
10. Open up the ruby file “Converter.rb”, this is the place where you do the mapping of the fields. There you have a lot of comments with good help with the mapping. :).
11. Now that you are done with your mapping. You enter the command `cd MigrationFolder`.

12. Enter the command `move-to-go run`.
	a.	Now Ruby maps the source-file data with the converter file you edited. Wich results in a XML file that contains the fetched data and that Go can read.
13. When it says “Source has been converted into ‘go_0.zip’.” You go ahead and log on to https://admin.staging.lime-go.com.
14. Add a new application by clicking on one of the nice Nordic flags (Preferably the flag that belong to the country you represent).
15. Enter a nice name and some info and click on “Submit”.
16. Now you press the button “Add an account” which is the one you’ll use when you enter the staging account. 
17. Under “Actions” you got some options, click on the link “Import data” to make a test migration. 
18. Just upload the .zip file and wait until the job has been finished (may take a while).
19. When the job is done, enter the account at https://go.staging.lime-go.com with the credentials you created in step 15.
20. Check the data.
	a. Is it how it should be?
	b. Is there many "Failed to match" tags? If yes you might have a problem with the identifications.
	c. If you have imported any external IDs, check them so they are correct. It's important to be abel to rerun the migration or add additional inormation at a later state. 
21. If yes, create an account (like at step 15) to the customer where they can look at the data aswell and give you a go to do the migration in the sharp environment. 

22. When the customer has approved of the test-migration you need a account for https://admin.lime-go.com/ to being able to do the migration in the production environment.
23. When you get in, search for an existing Application for the company. If it does, use it. 
24. Do step 16-19 but now in the production environment. 
25. Remove the application (from step 13) and migration job (step 16) from https://admin.staging.lime-go.com.
26. Remove the migration job from https//admin.lime-go.com. DO NOT REMOVE THE APPLICATION.

# POST MIGRATION
If you want to go the extra mile and make it easier for yourself and your collegues the next time, follow these steps:
1. Create a product folder for the migration on a share volume so cooperation is possible.
2. Can the source of the migration be used as a template for other migrations? 
3. Improve documentation on GitHub.
4. Improve [the checklist](Checklist.md) on GitHub.

