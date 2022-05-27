# orphansidcleanup
Powershell Script for Handling Orphaned SIDs in the Windows User Profile registry that resulted from a Windows Active Directory Domain Migration. 

These orphaned SIDs cause problems with the Windows 10 21H2 (and perhaps other) upgrade processes. You may have noticed that the signature check for the Windows 10 upgrade failing will return a result of no matching signatures. At least in our case it did. 

After some digging it was determined for my institition that the reason for the upgrade failures was due to duplicate Windows User Profiles listing the same path, but having different SIDs. This was a direct result of an Active Directory Domain User and Computer Migration. With over 400 hosts it would have been tedious to manually clean this up, or reset machines. This script is a result of that issue. 

The script provided should assist with cleaning up these SIDs. 

There are a few things of note: 

1. *I am not a programmer*, or event remotely adept at writing code. There are certainly things in this script that could be cleaned up and improved, I just didn't have a need to as the script functioned as is. 
2. You will want to test this script to make sure it is correct for your situation. 
3. I cannot promise this script will not cause additional problems. The script essentially just deletes registry entries in the ProfileList container. The script will backup the profilelist container to the root of the C: drive for recovery if needed. As a result you should be able to recover from any 'damage done'. 
4. I am not responsible for any damage caused to your systems as a result of running this script. I recommend you familiarize yourself with what is provided. 
5. Don't be like me and try to delete the duplicate users from the Profile manager tool in control panel. This *will delete their user data*. (I didn't do it initially, but my script had code that did at one point, which caused a colleague some stress. :) ) 

Additionally, you should take note of any users that may have had their names changed over the years, especially on older machines. This script uses the folder path of the user folder to determine the SamAccountName. If the SamAccountName is different than the folder path, it will result in a failed lookup and deletion of the registry entry. These values should be stored as SIDs in the $marriageSIDS variable. 

## What to edit ##
*$invalidUsers* - Users that you might not have migrated, but might exist on both domains. The script will just ignore these users. Typically these are admin or service accounts you wanted running in both domains simultaneously. 

*$marriageSIDS* - SIDs of users on the new domain that may have had their username changed as a result of marriage, divorce, or they just wanted to change their name. 

*$oldDomain* - This should be the old domain shortname, including the period

*$newDomain* - This should be the new domain shortname, including the period
