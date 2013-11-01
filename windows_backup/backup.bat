REM @echo off

REM Let's get the date in a format we can use for a filename
FOR /F "tokens=*" %%F IN ('Datefmt.bat yy mm dd /LZ') do SET Datefmt=%%F

REM move to the backups directory
cd e:
cd backups


REM Put all of the commands that you want to here
REM Use this space to copy things into the targets diretory
REM which is what will be backed up

xcopy /E e:\git\*.* e:\backups\target\

REM End of commands

REM create an archive

"C:\Program Files\7-Zip\7z.exe" a e:\backups\temp\backup_%Datefmt%.zip

REM Cleanup the Targets directory

rmdir e:\backups\target /s /q
mkdir e:\backups\target

REM move it to The Cloud!

%SystemRoot%\syswow64\WindowsPowerShell\v1.0\powershell.exe e:\backups\tools\backup_powershell.ps1
