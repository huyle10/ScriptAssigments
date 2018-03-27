Import-Module ActiveDirectory
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

################################################

#check if this script has run on this machine before (checking for log) - if not, create log file, if so, erase log contents
$log = "C:\security_group_check.log"
if (Test-Path $log) {
    try{
            Clear-Content $log
        } catch {
            " 
    ==============REMOTE LOG WIPE ERROR==============
        $error" | Add-Content $log  
    }
}

# Functions
    # Function 1: Get user AD Group Membership
    Function GetADMembership () {
        $ADMembership = Get-ADPrincipalGroupMembership $getUsername | Select-Object -Property name  | More
        $Result1 = Write-Output $ADMembership
        
        # Logging
        Write-Output "$getUsername is a Member of: " | Out-File $log -Append
        $ADMembership | Out-File $log -Append
        return $Result1
    }

    # Function 2: Retrieve last logon detail
    Function GetLogonDetail() {
        # Command reference: https://confluence.genevatrading.com/display/OPS/Finding+what+machines+a+user+has+been+logging+into
        $global:logonDetail = Get-ADuser -filter * -Properties otherMobile | Select-Object Name,SamAccountName,otherMobile | Where-Object -Property SamAccountName -Match "\b$getUsername\b" | ForEach-Object{$_.otherMobile[0]}
        
        # Logging
        Write-Output "$getUsername's Last Logon" | Out-File $log -Append
        $logonDetail | Out-File $log -Append
        return $logonDetail
    }

    #Function 3
    function checkRemote (){
        try {
        # Extract computername from Function 2 $logonDetail
        $computer = $logonDetail.Substring(31,9)
        $group = [ADSI]"WinNT://GENEVATRADING/$computer/Remote Desktop Users, group"
        $members = $group.psbase.Invoke("Members")
        $RDG = $members | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
        if ($RDG -contains $getUsername) {
            Add-Content $log "Check Remote User Access: $getUsername is in Remote Desktop Group "
            Write-Output "$getUsername is in Remote Desktop Group for $computer"
        } else {
            Add-Content $log "Check Remote User Acces: $getUsername is not in Remote Desktop Group for $computer "
            Write-Output "$getUsername is NOT in Remote Desktop Group for $computer"
        }
        } catch {
            Add-Content $log "Check Remote User Access Error: $error " 
            Write-Output "Error during check remote desktop users step"
        }
    }

# Main Execution
Do
{
    # Hello screen    
    Clear-Host
    Write-Output "Welcome to Geneva Trading, $env:UserName!`n"
    $message = "Please enter the username (use first initial and last name e.g. hle)"
    # Sub-Loop: check user existence 
    Do
    {
        # Get a username from the user
        $global:getUsername = Read-Host -prompt $message

        Try
        {
            # Check if it's in AD
            $checkUsername = Get-ADUser -Identity $getUsername -ErrorAction Stop
        }
        Catch
        {
            # Couldn't be found
            Write-Warning -Message "Could not find a user with the username: $getUsername. Please check the spelling and try again."

            # Loop de loop (Restart)
            $getUsername = $null
        }
    }
    While ($getUsername -eq $null)

    # Main Script Start Here

    # Peforming query
    Write-Output "`nQuerying $getUsername"

    # Function 1
    Write-Output "`n===========================================================" 
    Write-Output "$getUsername's Security Group Membership"
    GetADMembership 

    # Function 2
    Write-Output "`n==========================================================="
    Write-Output "$getUsername's Last Logon"
    GetLogonDetail

    # Function 3
    Write-Output "`n===========================================================" 
    checkRemote

    Write-Output "`n===========================================================" 
    Write-Output "Log is saved in C:\security_group_check.log"
    $response = Read-Host -Prompt "Do you want to Repeat?y/n"

} While ($response -eq "y")