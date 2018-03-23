$global:myPC = $env:COMPUTERNAME
Clear-Host
$global:PCname = Read-Host "Please enter the PC name you are checking"
$global:PCaccess = Read-Host "Will this be a PC that has access to the internet (yes/no)"

$global:username = Read-Host "Please enter the user's first initial and last name"
write-host "`nChecking Credentials..."

#Get users AD groups they are part of and test if they are in ITstaff and allowed to run this script
$username = $ENV:USERNAME
$usergroups = Get-ADUser $username -properties MemberOf | select -ExpandProperty memberof
if ($usergroups -match 'ITStaff') 
	{
    	write-host "You are part of the IT team." -foregroundcolor Green
    }
    else
    {
    	write-host "You are not part of the IT team, please rerun with correct credentials" -foregroundcolor Red
        start-sleep -s 5
        exit
    }

#checks to see if there is already a machine setup check log from a previous run, if there is, it is deleted
if (Test-Path C:\Users\$ENV:USERNAME\Desktop\machine_setup_check.log) {
try{
        Remove-Item -Path C:\Users\$ENV:USERNAME\Desktop\machine_setup_check.log -ErrorAction SilentlyContinue
      } catch {
          " 
==============LOCAL LOG REMOVAL ERROR==============
    $error" | Add-Content $log  
}
}

#connects to the remote computer in order to run checks on it
try {
$return = Invoke-Command -ComputerName $PCname -Argumentlist $username, $myPC, $PCaccess -ScriptBlock {

#check if this script has run on this machine before (checking for log) - if not, create log file, if so, erase log contents

$log = "C:\machine_setup_check.log"
if (Test-Path $log) {
try{
        Clear-Content $log
      } catch {
          " 
==============REMOTE LOG WIPE ERROR==============
    $error" | Add-Content $log  
}
}

#create local variables
$computer = $env:COMPUTERNAME
$global:myPC = $args[1]
$global:username = $args[0]
$global:PCaccess = $args[2]
$date = Get-Date -format "dd.mm.yyyy"
$global:location = $computer.Substring(0,3).toLower()
$global:totalNames = ("bas", "chi", "gch", "gln", "gny", "cme", "tel", "cor", "dub", "frk", "ice", "lnd", "nyc", "sec", "rem", "inx", "tok", "tor", "clr")
$global:pcType = $computer.Substring(5,1).toLower()
$global:currentnic = "Ethernet Converged Network adapter x550"
$global:installednic = (Get-WmiObject win32_networkadapter | where name -match "550").name
$global:currentGraphic= "NVIDIA NVS 510"
$global:installedGraphic= wmic path win32_videocontroller get name
$global:ramUnedited = Get-WmiObject -class "Win32_ComputerSystem"
$global:RAM = [Math]::Round(($ramUnedited.TotalPhysicalMemory/1GB),2)
$global:firewall = netsh advfirewall show all state
$global:goodNames = @("maintenance", "Administrator", "Machine_setup", "defaultaccount")
$global:neededASoftwares = @("HipChat", "Java", "FireFox", "Google", "Adobe Flash", "Unchecky", "Notepad", "Zip", "Office 16", "Adobe Acrobat Reader", "Traps")
$global:neededPSoftwares = @("HipChat", "Java", "FireFox", "Google", "Adobe Flash", "Unchecky", "Notepad", "Zip", "Office 16", "Adobe Acrobat Reader")
if ($pcType -eq "p") {
    $prodType = Read-Host "`nWill this production machine be using Gscaper, TT, or neither (gscalper, TT, none)"
}
#================================================================MAIN FUNCTIONS==========================================================================


#This function will check to make sure the PC follows our naming convention
function checkName {
  try {
    if ($totalNames -contains $location) {
        write-host "Good Name: $computer" -ForegroundColor Green
        Add-Content $log "Date: $date `r`nCheck Name: Good name "
        return $true
        } else { 
        Write-Host "Bad Name: $computer" -ForegroundColor Red
        Add-Content $log "Check Name: Bad name - $computer "
        return $false
        }
    } catch {
    Add-Content $log " CHECK NAME ERROR: $error "
}
}

#This function will check to make sure the machine has the correct amount of RAM
function checkRam { 
try {
    if (($pcType -eq "a") -And ($RAM -gt 7.5) -And ($RAM -lt 8.5)) {
        Write-Host "Correct RAM, $RAM, for the Admin machine." -ForegroundColor Green
        Add-Content $log "Check RAM: Good RAM for Admin machine. "
      }
    ElseIf (($pcType -eq "a") -and ($RAM -gt 10)) {
        Write-Host "Too much RAM: $RAM for Admin machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too much RAM ($RAM) for Standard Admin Machine. " 
      }
    ElseIf (($pcType -eq "a") -and ($RAM -lt 7)) {
        Write-Host "Too little RAM: $RAM for Admin machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too little RAM ($RAM) for Standard Admin Machine. " 
      }
    ElseIf (($pcType -eq "p") -and ($RAM -gt 15.5) -And ($RAM -lt 16.5)) {
        Write-Host "Correct RAM, $RAM for the production machine." -ForegroundColor Green
        Add-Content $log "Check Ram: Good RAM for Production machine. "
      }
    ElseIf (($pcType -eq "p") -And ($RAM -gt 16.5)) {
        Write-Host "Too much RAM: $RAM for this production machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too much ram ($RAM) for Production machine. "
      }
    ElseIf (($pcType -eq "p") -And ($RAM -lt 15)) {
        Write-Host "Too little RAM: $RAM for this production machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too little ram ($RAM) for Production machine. " 
      }
          ElseIf (($pcType -eq "d") -and ($RAM -gt 15.5) -And ($RAM -lt 16.5)) {
        Write-Host "Correct RAM, $RAM for the production machine." -ForegroundColor Green
        Add-Content $log "Check Ram: Good RAM for Production machine. "
      }
    ElseIf (($pcType -eq "d") -And ($RAM -gt 16.5)) {
        Write-Host "Too much RAM: $RAM for this production machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too much ram ($RAM) for Production machine. "
      }
    ElseIf (($pcType -eq "d") -And ($RAM -lt 15)) {
        Write-Host "Too little RAM: $RAM for this production machine." -ForegroundColor Red
        Add-Content $log "Check Ram: Too little ram ($RAM) for Production machine. " 
      }
    Else {
        Write-Host "PC RAM: " $RAM  "- Failed RAM Check for $pcType." -ForegroundColor Yellow
        Add-Content $log "Check Ram: Failed RAM Check "
        }
       
} Catch {
    Add-Content $log "Check Ram: $error "
    Write-Host "RAM Check error" -ForegroundColor Yellow
}
}

#this function will check to make sure the PC is on the genevatrading.com domain
function checkDomain {
try {
    if ((Get-WmiObject -Class win32_computersystem).partofdomain -eq $true) {
        Write-Host "Correct Domain: genevatrading.com" -ForegroundColor Green
        Add-Content $log "Domain Check: Correct Domain "
    } else {
        Write-Host "Incorrect Domain" -ForegroundColor Red
        Add-Content $log "Domain Check: Incorrect Domain "
    
    }
 } catch {
    Add-Content $log "Domain Check $error"
    Write-Host "Domain Check error." -ForegroundColor Yellow
}
}

#This function will check to see if the correct video card is installed
function checkNvidia {
try {
    if ($installedGraphic -match $currentGraphic) {
        Write-Host "Correct graphics card: Nvidia NVS 510 installed" -ForegroundColor Green
        Add-Content $log "Nvidia Check: Correct graphics card "
    } else {
        Write-Host "Incorrect graphics card: Nvidia NVS 510 NOT installed" -ForegroundColor Red
        Add-Content $log "Nvidia Check: Wrong graphics card "
    }
} catch {
    Add-Content $log "Check Nvidia Error: $error"
    Write-Host "Check Nvidia error." -ForegroundColor Yellow
}
}

#This function will check to see if the correct NIC is installed
function checkX550 {
try {
    if ($installednic -match $Currentnic) {
        Write-Host "Correct NIC installed" -ForegroundColor Green
        Add-Content $log "Check NIC: Correct NIC: Intel X550 " 
    }
    else { 
        Write-Host "Incorrect NIC" -ForegroundColor Red
        Add-Content $log "Check NIC: Incorrect NIC: No Intel X550 detected "
    }
} catch {
add-content $log "Check NIC Errro: $error "
Write-Host "Error during X550 NIC check" -ForegroundColor Yellow
Start-Sleep -S 4
}
}

#This function will check to see if the Intel Powershell module is installed
function checkIntelModule {
try {
    if ((Get-Module -ListAvailable | where name -eq "IntelNetCmdlets") -ne $null) {
        Write-Host "Intel Powershell Module Installed" -ForegroundColor Green
        Add-Content $log "Check Intel Module: Installed "
        return $true
    } else {
        write-host "Intel Powershell Module not Installed, rerun the driver installation and make sure 'Powershell Module' is selected" -ForegroundColor Red
        Add-Content $log "Check Intel Module: NOT Installed "
        return $false
}       
} catch {
    add-content $log "Check Intel Powershell Module Error: $error "
Write-Host "Error during check powershell Intel module" -ForegroundColor Yellow
Start-Sleep -S 4

}
}


#This function will check to see if the X550 NIC is optimized
function checkOptimizeNIC {
$global:NICoptimizeIssues=@()
try{
    if ($installednic -match $Currentnic) {
        Import-Module IntelNetCmdlets
        if ((Get-IntelNetAdaptersetting -Name $installednic -displayname 'Flow Control').displayvalue -match "Disabled"){
        
        } else {
            $NICoptimizeIssues+= "Flow Control, "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Interrupt Moderation").displayvalue -eq "Disabled"){

        } else {
            $NICoptimizeIssues+= "Interrupt Moderation, "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Large Send Offload V2 (IPv4)").DisplayValue -eq "Disabled"){
        
        } else {
            $NICoptimizeIssues+= "Large Send Offload V2 (IPv4), "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Large Send Offload V2 (IPv6)").DisplayValue -eq "Disabled"){
         
        } else {
            $NICoptimizeIssues+= "Large Send Offload V2 (IPv6), "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "IPsec Offload").DisplayValue -eq "Disabled"){
       
        } else {
            $NICoptimizeIssues+= "IPsec Offload, "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "IPv4 Checksum Offload").DisplayValue -eq "Disabled"){
        
        } else {
            $NICoptimizeIssues+= "IPv4 Checksum Offload, " 
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "TCP Checksum Offload (IPv4)").DisplayValue -eq "Disabled"){
        
        } else {
            $NICoptimizeIssues+= "TCP Checksum Offload (IPv4), "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "UDP Checksum Offload (IPv4)").DisplayValue -eq "Disabled"){
            
        } else {
            $NICoptimizeIssues+= "UDP Checksum Offload (IPv4), "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "UDP Checksum Offload (IPv6)").DisplayValue -eq "Disabled"){
     
        } else {
            $NICoptimizeIssues+= "UDP Checksum Offload (IPv6), "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Interrupt Moderation Rate" | select DisplayValue) -match "Off"){
        
        } else {
            $NICoptimizeIssues+= "Interrupt Moderation, "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Receive Buffers" | select DisplayValue) -match "4096"){
           
        } else {
            $NICoptimizeIssues+= "Interrupt Moderation Rate, "
        }
        if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Transmit Buffers" | select DisplayValue) -match "16384"){
         
        } else {
            $NICoptimizeIssues+= "Trasmit Buffers"
        }
         if ((Get-IntelNetAdaptersetting -Name $installednic -DisplayName "Receive Side Scaling Queues").DisplayValue -eq "4 Queues"){
            
        } else {
            $NICoptimizeIssues+= "Receive Side Scaling Queues, "
        }
          if ($NICoptimizeIssues.Length -lt 1) {
           Write-Host "Correct NIC Optimized Settings" -ForegroundColor Green
        } else { 
           Write-Host "Incorrect NIC Optimized Settings: $NICoptimizeIssues " -ForegroundColor Red
        }
        } else { 
            write-host "Did not check NIC settings due to incorrect NIC" -ForegroundColor Red
    }
    } catch { 
     add-content $log "Check NIC Optimization Error: $error "
     $NICoptimizeIssues+=$error
     write-host "Error during NIC Optimization Check"
}
   Add-Content $log "Check NIC Optimization: NOT Optimized Settings: $NICoptimizeIssues "

}


#This function will check to make sure that all drivers are installed
function checkDrivers {
try {
    if (Get-WmiObject Win32_pnpEntity | where ConfigManagerErrorCode -eq 28) {
          Add-Content $log "Drivers missing" (Get-WmiObject Win32_pnpEntity | where ConfigManagerErrorCode -eq 28 |Format-Table name, PNPclass)
        write-host "Drivers missing" -ForegroundColor Red
        write-host (Get-WmiObject Win32_pnpEntity | where ConfigManagerErrorCode -eq 28).name
    } else {
        Add-Content $log "Check Drivers: All drivers installed " 
        Write-Host "All drivers installed" -ForegroundColor Green
           }
} catch {
Add-Content $log "Check Drivers Error: $error "
Write-Host "Error during Drivers check" -ForegroundColor Yellow
}
}

#This function will check to make sure Windows Firewall is turned off
function checkFirewall {
try {
if ($firewall -notcontains "ON") {
    Write-Host "Correct Firewall: Private, Public, and Domain Windows Firewall are OFF" -ForegroundColor Green
    Add-Content $log "Check Firewall: Correct Windows Firewall: ALL OFF " 
} else { 
    Write-Host "Correct Firewall: Private, Public, or Domain Windows Firewall is ON" -ForegroundColor Red
    Add-Content $log "Check Firewall: Incorrect Windows Firewall: NOT ALL OFF "
 }
} catch { 
add-content $log "Check Firewall Error: $error "
Write-Host "Error during Firewall check" -ForegroundColor Yellow
}
}

#This function will check to see if all neeeded software is installed
function checkSoftware {
try {
$installed=@()
$notinstalled=@()
$PCaccess = $PCaccess.substring(0,1).tolower()
if($PCaccess -match "y"){
    foreach ($neededASoftware in $neededASoftwares){
           if (((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName) -match $neededASoftware) -or (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName) -match ($neededASoftware)) {
               $installed+="$neededASoftware, "
           } else {
               $notinstalled+="$neededASoftware, "
        }
      }
} else {
    foreach ($neededPSoftware in $neededPSoftwares) {
        if (((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName) -match $neededPSoftware) -or (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName) -match ($neededPSoftware)) {
            $installed+="$neededPSoftware, "
        } else {
            $notinstalled+="$neededPSoftware, "
        }
      }
    }
    
     Add-Content $log "Check Software: Installed: $installed ; Not Installed: $notinstalled "

     if ($notinstalled -ne $null) {
        Write-Host  "Software not Installed: $notinstalled" -ForegroundColor Red
        Write-Host  "Software Installed: $installed" -ForegroundColor Green
    } else { 
        Write-Host "All Software Installed: $installed" -ForegroundColor Green
}
} catch { 
add-content $log "Check Software Error: $error "
Write-Host "Error during Software check" -ForegroundColor Yellow
}
}

function checkTradingSoftware {
if ($prodType) {
    if ($prodType -eq "gscalper") {
        try {
            if (test-path C:\Gscalper) {
                write-host "--------------------------------------"
                write-host "Gscalper installed" -foregroundcolor Green
            } else {
                write-host "--------------------------------------"
                write-host "Gscalper not installed" -foregroundcolor Red
            }
        } catch {
            add-content $log "Check Trading Software Error: $error "
            Write-Host "Error during Trading Software check" -ForegroundColor Yellow
        }

    } elseif ($prodType -eq "tt") {
            try {
            if (test-path C:\tt) {
                write-host "--------------------------------------"
                write-host "Gscalper installed" -foregroundcolor Green
            } else {
                write-host "--------------------------------------"
                write-host "Gscalper not installed" -foregroundcolor Red
            }
        } catch {
            add-content $log "Check Trading Software Error: $error " 
        write-host "--------------------------------------"
        Write-Host "Error during Trading Software check" -ForegroundColor Yellow
        }
    } elseif (($prodType -eq "none") -or ($prodType -eq "neither")) {
    } else {
        write-host "--------------------------------------"
        write-host "Not checking for production programs, entry not recongized. Please rerun and enter either, gscalper, TT, or none/neither"
    }
}
}

#This function will check to see if there are any Windows Updates available
function winUpdates {
try{
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -name NoAutoUpdate -value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -name AUOptions -value 3
$criteria = "Type='software' and IsAssigned=1 and IsHidden=0 and IsInstalled=0"
$search = (New-Object -COM Microsoft.Update.Session).CreateUpdateSearcher()
$updates = $search.Search($criteria).Updates

if ($updates.Count -eq 0) {
  Add-Content $log "Check Win Updates: Windows is up to date " 
  Write-Host "Windows up to date" -ForegroundColor Green
} else {
    Write-Host "Windows Updates needed" -ForegroundColor Red
  Add-Content $log "Check Win Updates: Windows Updates Needed "
}
} catch {
   add-content $log "Check Win Updates Error: $error "
Write-Host "Error during Windows Updates check" -ForegroundColor Yellow
}
}   

#This function will check to make sure the user is added to the remote desktop users group
function checkRemote {
try {
$group = [ADSI]"WinNT://GENEVATRADING/$computer/Remote Desktop Users, group"
$members = $group.psbase.Invoke("Members")
$RDG = $members | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
if ($RDG -contains $username) {
 Add-Content $log "Check Remote User Access: $username is in Remote Desktop Group "
Write-Host "$username is in Remote Desktop Group for $computer" -ForegroundColor Green
} else {
 Add-Content $log "Check Remote User Acces: $args is not in Remote Desktop Group for $computer "
Write-Host "$username is NOT in Remote Desktop Group for $computer" -ForegroundColor Red
}
} catch {
   add-content $log "Check Remote User Access Error: $error " 
Write-Host "Error during check remote desktop users step" -ForegroundColor Yellow
}
}

#This function will check if there are any local user accounts that were created during setup and need to be removed
function badLocal {
    $global:ADSI = [adsi]"WinNT://$computer"
    $global:users = $ADSI.Children | where {$_.SchemaClassName -eq 'user'} | select path
    $global:goodUser=@()
    $global:badUser=@()
    foreach ($user in $users.path) {
    try {
            $user = ($user.Replace("WinNT://GENEVATRADING/$computer/", "")).Trim()
        if ($user -notin $goodNames) {
            $badUser += "$user, "
       } else {
            $goodUser+= "$user, "
       }

    } catch {
         add-content $log "Check Local Users Error: $error + $user "
            } 
   }
   Add-Content $log "Check Local Users: Remove: $badUser ; Ok: $goodUser " 

   Write-Host "Good Local Users: $goodUser" -ForegroundColor Green
   Write-Host "Bad Local Users: $badUser" -ForegroundColor Red
}

            
#================================================================MAIN EXECUTION=======================================================================
write-host "`n-----------------------PC SETUP CHECK-----------------------------" -ForegroundColor Yellow
if (checkname) {
write-host "--------------------------------------"
    checkRam
} else {
    Write-Host "Incorrect naming convention, not checking RAM" -ForegroundColor Red
} 
write-host "--------------------------------------"
checkDomain
write-host "--------------------------------------"
checkNvidia
write-host "--------------------------------------"
winUpdates
write-host "--------------------------------------"
checkIntelModule
write-host "--------------------------------------"
checkX550 
write-host "--------------------------------------"
checkOptimizeNIC
write-host "--------------------------------------"
checkRemote
write-host "--------------------------------------"
checkDrivers
write-host "--------------------------------------"
checkFirewall
write-host "--------------------------------------"
checkSoftware
checkTradingSoftware
write-host "--------------------------------------"
badLocal
write-host "--------------------------------------"
write-host "Copying log to local computer..."

return (Get-Content $log)
Remove-Item $log
}
} catch {
write-host "Error connecting to PC, this may be because Powershell is outdated"
Write-Host "Error: $error"
} 

#This adds the content of the log on the remote computer to the log on the local computer running the script
$return | Add-Content "C:\Users\$ENV:USERNAME\Desktop\machine_setup_check.log"

Write-Host "`nPress any key to continue ..."

$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
