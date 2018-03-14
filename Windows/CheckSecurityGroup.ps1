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

# Hello screen
Clear-Host
Write-Host "Welcome to Geneva Trading, $env:UserName!`n"
$myuser = Read-Host "Please enter your username to be queried"

# Check if User exist
$Results = [bool](Get-ADUser -Filter { SamAccountName -eq $myuser })
If($Results -eq 0) 
{ 
    Write-Warning "Cannot find the AccountName '$myuser'. Please make sure that it exists." 
}
Else # Main script here
{
    # Peforming query
    Write-Output "`nQuerying $myuser`n"

    # Security Group
    Write-Output "`n===========================================================" 
    Write-Output "$myuser's Security Group Membership"
    Get-ADPrincipalGroupMembership $myuser | Select-Object -Property name | more

    # Last log-on: Call Custom Function 1
    Write-Output "`n==========================================================="
    Write-Output "$myuser's Last Logon"
    $output = Get-ADUserLastLogon -UserName $myuser 
    # output to console        
    Write-Output "$output" | more
    # Check if user belong to vpn_sg
    Write-Output "`n==========================================================="
    Write-Output "IS $myuser a remote user?"
    Test-ADGroupMember "$myuser" "vpn_sg" | more

}

Get-ADUser -Identity HawkingS | Move-ADObject -TargetPath "OU=Inactive Users,DC=contoso,DC=com"