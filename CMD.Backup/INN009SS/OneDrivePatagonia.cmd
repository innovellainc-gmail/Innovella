@ECHO OFF
SETLOCAL

REM
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM	https://technet.microsoft.com/en-us/magazine/2009.04.utilityspotlight.aspx
REM

@ECHO OFF
SETLOCAL

:DEFAULTS
REM HQ1NAS01P01 (Current)
REM INN009SS
REM \\HQ1NAS01P01\Backups\INN009SS\CDRIVE
SET _remote=172.16.1.51
SET _remote=192.168.102.141

SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE
SET _source=\\%_local%\C$

SET _what=/MIR /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:"\\%_local%\C$\Backups\OneDrivePatagonia.log.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\Backups\OneDrivePatagonia.log.txt" /FP /NS /NP /TEE
SET _exclude=/XD "%_source%Apps" "%_source%Backups" "%_source%Dell"

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

REM	This next line sets up a share from host to remote. Sharenames don't us C$ on the remote!
REM	NET USE \\$_remote\IPC$ /u:$_username $_password

:ONEDRIVE-PATAGONIA
SET _source="\\%_local%\C$\Users\sshac\OneDrive - Patagonia"
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE\Users\sshac\OneDrivePatagonia
SET _exclude=/XD %_source%\Notebooks
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D
