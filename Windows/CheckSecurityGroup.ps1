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
    #Function 1
    Function Test-ADGroupMember($User,$Group) {
        Trap { Add-Content $log "Test-AdGroupMember Error: $error "  }
        If (Get-ADUser -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group).DistinguishedName)'" -SearchBase $((Get-ADUser $User).DistinguishedName)) { 
            $true
            Add-Content $log "$getUsername is a VPN user."
        }
        Else { 
            $false 
            Add-Content $log "$getUsername is not a VPN user."
        }
    }

    #Function 2
    function checkRemote {
        try {
        $group = [ADSI]"WinNT://GENEVATRADING/$computer/Remote Desktop Users, group"
        $members = $group.psbase.Invoke("Members")
        $RDG = $members | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
        if ($RDG -contains $getUsername) {
            Add-Content $log "Check Remote User Access: $getUsername is in Remote Desktop Group "
            Write-Host "$getUsername is in Remote Desktop Group for $computer" -ForegroundColor Green
        } else {
            Add-Content $log "Check Remote User Acces: $getUsername is not in Remote Desktop Group for $computer "
            Write-Host "$getUsername is NOT in Remote Desktop Group for $computer" -ForegroundColor Red
        }
        } catch {
            Add-Content $log "Check Remote User Access Error: $error " 
            Write-Host "Error during check remote desktop users step" -ForegroundColor Yellow
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

    # Security Group
    Write-Output "`n===========================================================" 
    Write-Output "$getUsername's Security Group Membership"
    Get-ADPrincipalGroupMembership $getUsername | Select-Object -Property name | more

    # Check Last log-on: 
    Write-Output "`n==========================================================="
    Write-Output "$getUsername's Last Logon"
    # Command reference: https://confluence.genevatrading.com/display/OPS/Finding+what+machines+a+user+has+been+logging+into
    $logonDetail = Get-ADuser -filter * -Properties otherMobile | Select-Object Name,SamAccountName,otherMobile | Where-Object -Property SamAccountName -Match "\b$getUsername\b" | ForEach-Object{$_.otherMobile[0]}
    Write-Output $logonDetail

    # Check if user belong to vpn_sg
    Write-Output "`n==========================================================="
    Write-Output "Is $getUsername a VPN user?"
    # Call Function 2
    Test-ADGroupMember "$getUsername" "vpn_sg"

    # Check if user is added to remote user group in last logon computer
    Write-Output "`n===========================================================" 
    # Extract computername from last logon
    $computer = $logonDetail.Substring(31,9)
    checkRemote

    Write-Output "`n===========================================================" 
    Write-Output "Log is saved in C:\security_group_check.log"
    $response = read-host "Do you want to Repeat?y/n"

} While ($response -eq "y")