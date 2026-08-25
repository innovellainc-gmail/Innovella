@ECHO OFF
SETLOCAL
REM
REM	Append all OneDrive files to the NAS device. DOES NOT MIRROR
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM
REM	This command file to be executed from a single INNOVELLA device: INN009SS
REM	SOURCE:	\\INN009SS\Users\sshac\OneDrive
REM	TARGET:	\\HQ1NAS01P01\Backups\OneDrive
REM
@ECHO OFF
SETLOCAL
REM SET /P _remote=Please enter the remote hostname/IP address (%_remote%): 
REM IF "%_remote%"=="" GOTO Error
REM SET _remote=HQ1NAS01P01

:DEFAULTS
SET _remote=172.16.1.51
SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$\Users\sshac\OneDrive
SET _dest=\\%_remote%\Backups\OneDrive
SET _what=/IS /IT /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:\\%_local%\C$\Backups\add.OneDrive.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\add.OneDrive.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\Music %_source%\Software %_source%\Videos

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%
REM
REM	Add source files to \\HQ1NAS01P01\Backups\OneDrive folders only.
REM	Does not use the mirror command so no files are erased.
REM

:ONEDRIVE
ROBOCOPY "%_source%" "%_dest%" %_what% %_logs% %_exclude%
goto finish

:DESKTOP
ROBOCOPY "%_source%\Desktop" "%_dest%\Desktop" %_what% %_logs% %_exclude%

:DOCUMENTS
ROBOCOPY "%_source%\Documents" "%_dest%\Documents" %_what% %_logs% %_exclude%

:PRIVATE
ROBOCOPY "%_source%\Private" "%_dest%\Private" %_what% %_logs% %_exclude%

:PUBLIC
ROBOCOPY "%_source%\Public" "%_dest%\Public" %_what% %_logs% %_exclude%

:SOFTWARE
ROBOCOPY "%_source%\Software" "%_dest%\Software" %_what% %_logs% %_exclude%

:WORKSPACES
ROBOCOPY "%_source%\workspaces" "%_dest%\Workspaces" %_what% /R:0 /W:0 %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D
popd


