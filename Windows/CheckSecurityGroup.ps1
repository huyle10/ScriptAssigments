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

# Custom functions
    # Function 1
    function Get-ADUserLastLogon([string]$userName)
    {
    $dcs = Get-ADDomainController -Filter {Name -like "*"}
    $time = 0
    foreach($dc in $dcs)
    { 
        $hostname = $dc.HostName
        $user = Get-ADUser $userName | Get-ADObject -Properties lastLogon 
        if($user.LastLogon -gt $time) 
        {
        $time = $user.LastLogon
        }
    }
    $dt = [DateTime]::FromFileTime($time)
    return $dt
    }

    #Function 2
    Function Test-ADGroupMember($User,$Group) {
        Trap { Return "error" }
        If (Get-ADUser -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group).DistinguishedName)'" -SearchBase $((Get-ADUser $User).DistinguishedName)) { $true }
        Else { $false }
    }

# Main Loop
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
        $getUsername = Read-Host -prompt $message

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
    Write-Output "`nQuerying $getUsername`n"

    # Security Group
    Write-Output "`n===========================================================" 
    Write-Output "$getUsername's Security Group Membership"
    Get-ADPrincipalGroupMembership $getUsername | Select-Object -Property name | more

    # Last log-on: Call Custom Function 1
    Write-Output "`n==========================================================="
    Write-Output "$getUsername's Last Logon"
    $output = Get-ADUserLastLogon -UserName $getUsername 
    # output to console        
    Write-Output "$output" | more
    # Check if user belong to vpn_sg
    Write-Output "`n==========================================================="
    Write-Output "IS $getUsername a remote user?"
    Test-ADGroupMember "$getUsername" "vpn_sg" | more

    $response = read-host "Do you want to Repeat?y/n"

    $group = read-host "enter group name, eg:(core-tech_sg)"
    Get-ADGroupMember -Recursive $group |% { get-aduser $_ -Properties otherMobile | Select-Object Name,otherMobile} | Sort-Object Name | Out-Gridview -title "User Logins"

} While ($response -eq "y")