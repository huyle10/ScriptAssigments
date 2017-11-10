 # Batch File to execute all .exe in a folder and subfolders
 
 # Change the reference to the current folder (".") to your needs.
 # Use switch /s for silent install
 
 for /r "." %%a in (*.exe) do %%~fa
