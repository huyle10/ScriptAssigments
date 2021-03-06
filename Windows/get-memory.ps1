<#
.SYNOPSIS
Get Trader Information
.DESCRIPTION
This script will get the installed physical memory of Chicago and Dublin Trader Computer listed in Traderlist.txt.
.NOTES  
The script will execute the commands on multiple machines sequentially using non-concurrent sessions.
The info will be exported to a csv format.
Requires: a .csv file path
#>

#Get Active computer list in the last 28 days
$Date = (Get-Date).AddDays(-28)
#$ActiveComputers = Get-ADComputer -Filter {LastLogonDate -gt $Date} | Select-Object Name 
#$ActiveComputers | Out-File 'C:\ActiveComputers.txt'

#Import a computer list (feel free to change the path)
#$list = Get-Content 'C:\ActiveComputers.txt' | Select-String -Pattern 'CHIWWP\d\d\d','DUBWWP\d\d\d' -AllMatches | Sort-Object

#Query Computer list
$computerList = Get-ADComputer -SearchScope Subtree -SearchBase 'OU=Workstations,OU=GTComputers,OU=GENEVATRADING,DC=genevatrading,DC=com' -Filter {LastLogonDate -gt $Date -and Name -like "CHIWWP*" -or Name -like "DUBWWP*"} | Select-Object -Exp Name
#Filter computername using regular express (modify the query if neccessary)  - in this case, Chicago and Dublin trader machines
# $csv = Get-Content $list | Select-String -Pattern 'CHIWWP\d\d\d','DUBWWP\d\d\d' -AllMatches | Sort-Object

$infoColl = @()
Foreach ($c in $computerList)
{
	#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
	$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $c | Measure-Object -Property capacity -Sum | ForEach-Object { [Math]::Round(($_.sum / 1GB), 2) }
	$infoObject = New-Object PSObject

	#The following add data to the infoObjects.	
	Add-Member -InputObject $infoObject -memberType NoteProperty -name "ComputerName" -value $c
    Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
	$infoObject #Output to the screen for a visual feedback.
	$infoColl += $infoObject
}
# Export to .csv file in C:\ (feel free to change the path)
$infoColl | Export-Csv -path C:\Trader_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation #Export the results in csv file.
