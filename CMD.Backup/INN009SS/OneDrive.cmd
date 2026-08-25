@ECHO OFF
SETLOCAL

REM
REM 	FROM:	INN009SS\C$
REM 	TO:	\\HQ1NAS01P01\Backups\INN009SS\CDRIVE
REM

@ECHO OFF
SETLOCAL

:DEFAULTS
SET _remote=172.16.1.51
SET _remote=192.168.102.141

SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _dest=\\%_remote%\Backups\OneDrive
SET _source=\\%_local%\C$

SET _what=/IS /IT /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:"\\%_local%\C$\Backups\OneDrive.log.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\Backups\OneDrive.log.txt" /FP /NS /NP /TEE
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

goto ONEDRIVE-WORKSPACES


:ONEDRIVE
SET _source=\\%_local%\C$\Users\sshac\OneDrive
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE\Users\sshac\OneDrive
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source%\Desktop %_dest%\Desktop %_what% %_logs% %_exclude%
ROBOCOPY %_source%\Documents %_dest%\Documents %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\Microsoft Edge Collections" "%_dest%\Microsoft Edge Collections" %_what% %_logs% %_exclude%
ROBOCOPY %_source%\Pictures %_dest%\Pictures %_what% %_logs% %_exclude%

:ONEDRIVE-PRIVATE
SET _source=\\%_local%\C$\Users\sshac\OneDrive\Private
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE\Users\sshac\OneDrive\Private
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

:ONEDRIVE-PUBLIC
SET _source=\\%_local%\C$\Users\sshac\OneDrive\Public
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE\Users\sshac\OneDrive\Public
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

:ONEDRIVE-WORKSPACES
SET _source=\\%_local%\C$\Users\sshac\OneDrive\Workspaces
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE\Users\sshac\OneDrive\Workspaces
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D
