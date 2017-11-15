@echo off

net stop wuauserv
cd %windir%
cd SoftwareDistrubution
del /F /S /Q Download
net start wuauserv

for /f "tokens=4-5 delims=] " %%i in ('ver') do set VERSION=%%i
echo %VERSION%