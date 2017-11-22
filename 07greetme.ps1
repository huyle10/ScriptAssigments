# Author: Huy Le

# greetme.ps1 - the greetme program in Powershell

# Prompt input and collect information
$User = Read-Host -Prompt 'Please enter your full name'
$Date = Get-Date
$CompName = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name


# Output
Write-Host "Hello '$User'. How are you? Welcome to Windows Powershell Scripting."
Write-Host "Now it is '$Date.ToUniversalTime()'"
Write-Host "System Disk Information:"
Get-Disk
Write-Host "Computer Name is '$CompName'"
Write-Host "OS Name and Release:"
Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, OSArchitecture, BuildNumber | FL
Write-Host "Currently Running Processes:"
Get-Process
Write-Host "Machine IpAddresses"
Get-NetIPAddress | Format-Table
Write-Host "Goodbye '$User'. See you next time!"
