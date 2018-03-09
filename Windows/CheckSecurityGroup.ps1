# Author: Huy Le

# Intern Project: A powershell script to scan security group 

<# 
You will need to create a script which will scan a security group (defined by the script user) in powershell.
This script will check the members of the security group and find their last logged on pc, 
check the membership of the allowed remote user list. 

Script requests name of the user to be queried

Script retrieves the security group membership of the user through Active Directory

Script displays table with the security group memberships 

Script checks the last log on for the user

Using the hostname of the last logon for the user, the script checks if the user is part of the remote desktop users.  

Display the result. 
#>
 
Get-ADUser hle -Properties * 
