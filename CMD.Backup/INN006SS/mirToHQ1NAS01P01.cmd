@ECHO OFF
SETLOCAL

REM
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM	https://technet.microsoft.com/en-us/magazine/2009.04.utilityspotlight.aspx
REM
REM

@ECHO OFF
SETLOCAL
REM SET /P _remote=Please enter the remote hostname/IP address (%_remote%): 
REM IF "%_remote%"=="" GOTO Error
REM SET _remote=HQ1NAS01P01

:DEFAULTS
SET _remote=172.16.1.51
SET _remote=192.168.102.141

REM Due to security policies set by PDS, we must use the NetBIOS name not an IP
SET _remote=HQ1NAS01P01

SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE
SET _what=/MIR /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _exclude=/XD "%_source%\Users\sshac\Documents\My Music" %_source%\Users\sshac\Music %_source%\Users\sshac\iCloudDrive %_source%\Users\sshac\OneDrive %_source%\Innovella\OneDrive %_source%\Users\sshac\Pictures %_source%\Users\sshac\Videos

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%


:C-LOCALDRIVE
ROBOCOPY "%_source%\LocalDrive" "%_dest%\LocalDrive" %_what% %_log% %_exclude%
ROBOCOPY "%_source%\Temp" "%_dest%\Temp" %_what% %_log% %_exclude%
ROBOCOPY "%_source%\Users\sshac\Desktop" "%_dest%\Users\sshac\Desktop" %_what% %_log% %_exclude%
ROBOCOPY "%_source%\Users\sshac\Documents" "%_dest%\Users\sshac\Documents" %_what% %_log% %_exclude%
ROBOCOPY "%_source%\Users\sshac\Pictures" "%_dest%\Users\sshac\Pictures" %_what% %_log% %_exclude%
:DOWNLOADS
SET _exclude=/XA:SH
ROBOCOPY "%_source%\Users\sshac\Downloads" "%_dest%\Users\sshac\Downloads" %_what% %_log% %_exclude% /XO 


:D-LOCALDRIVE
SET _source=\\%_local%\D$
SET _dest=\\%_remote%\Backups\%_local%\DDRIVE
SET _log=/LOG:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\sshac\Music %_source%\sshac\OneDrive %_source%\sshac\Pictures %_source%\sshac\Videos

ROBOCOPY "%_source%\Downloads" "%_dest%\Downloads" %_what% %_logs%
ROBOCOPY "%_source%\Innovella" "%_dest%\Innovella" %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\LocalDrive" "%_dest%\LocalDrive" %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\Returns" "%_dest%\Returns" %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\Scans" "%_dest%\Scans" %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\Software" "%_dest%\Software" %_what% %_logs% %_exclude%
ROBOCOPY "%_source%\sshac" "%_dest%\sshac" %_what% %_logs% %_exclude%

goto FINISH

:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Following command keeps the console window open at the end
cmd /k