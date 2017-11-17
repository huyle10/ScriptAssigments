<#
.Synopsis
This is brief comments
.Description
This is the long comments
.Parameter ComputerName
This is the name of a remote computer
.Example
Connecting to local computer
DiskInfo -computername localhost
.Example
Connecting to remote computer
DiskInfo -computername DC
#>
param(
  [Parameter(Mandatory=$true)]
  [string[]]$computername,
  $NotForUse
)

# Main Code here
Get-CinInstance -ComputerName $computername -ClassName win32_logicaldisk -filter "DeviceID='c:'" -ComputerName DC |
  Select @{n="ComputerName";e={$_.PSComputername}},
         @{n="FreeGB";e={$_.Freespace / 1gb -as [int]}}
