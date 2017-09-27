# LDAP Bulking User Creation Process
This is temporal automation to create/update multiple LDAP users in Chef Automate.

## Prerequisites
The minimum prerequisites to be able to use this automation are:
* Use a Unix Workstation. (MAC, Linux, etc)
* Have ChefDK Installed. (https://downloads.chef.io/chef-dk/)
* Setup the CLI to point to your Automate Server. (https://asciinema.org/a/89658)
* Download the `bulk-user-creation.rb` script locally and give executable permissions to the file.

## Options
PRUNE: If you select 'yes' to prune the list, then any existing Automate users who DO NOT appear in your users list will be removed/deleted. This cannot be undone.

### Create list of users file
The automation will ask you to provide a file with the list of users to create
with the following format:
```
[USERNAME]|[ROLES]
[USERNAME]|[ROLES]
```
An example of this file at:

https://gist.github.com/afiune/ac5b4b7074ee9191a876d29ae73fe536#file-users-example-list

You may wish to automate a process to build/populate this user file from LDAP data on a semi-regular basis if you have a large Automate user base or your user base changes frequently.

## Run the automation
Once you have all the prerequisites in place, and the list of users to create, open a terminal and go to the directory that you have previously configured the delivery-cli to point to your Chef Automate Server.

Then run: `./bulk-user-creation.rb`
You will be prompted to specify the list file (path relative to execution directory).
You will be prompted to specify whether you wish to prune users.

```
$ ./bulk-user-creation.rb
Automate LDAP Bulk User Creation
Insert the user list file:users-example.list
Prune users not in user list file? (yes/no):yes
Evaluating list of Automate users to delete...
Existing user user1 not listed in input file... deleting...
Existing user admin in input file... retaining...
user2: user exists... updating roles...
roles updated.
user3: user exists... updating roles...
roles updated.
user4: user exists... updating roles...
roles updated.
user5: user exists... updating roles...
roles updated.
user6: user exists... updating roles...
roles updated.
```
