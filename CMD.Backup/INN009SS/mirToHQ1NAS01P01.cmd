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
SET _what=/MIR /COPY:DT /w:1 /r:1 /v /Z
			REM _what=/MIR /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\Innovella\OneDrive %_source%\Innovella\OOSQL.v4\Artifacts %_source%\Innovella\OOSQL.v4\Reference %_source%\Innovella\OOSQL.v4\IMG

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

:LOCALDRIVE
ROBOCOPY "%_source%\LocalDrive" "%_dest%\LocalDrive" %_what% %_exclude% %_log%

:AWS
ROBOCOPY "%_source%\AWS" "%_dest%\AWS" %_what% %_exclude% %_log%

:REGEDITS
ROBOCOPY %_source%\Regedits %_dest%\Regedits %_what% %_exclude%

:TEMP
ROBOCOPY "%_source%\Temp" "%_dest%\Temp" %_what% %_exclude% %_log%

:DOWNLOADS
SET _exclude=/XA:SH
ROBOCOPY "%_source%\Users\shacterso\Downloads" "%_dest%\Users\shacterso\Downloads" /XO

:WORKSPACES
SET _exclude=/XD %_source%\Innovella\OneDrive
ROBOCOPY "%_source%\Users\shacterso\Workspaces" "%_dest%\Users\shacterso\Workspaces" %_what% %_exclude% %_log%

:DESKTOP
SET _exclude=/XD %_source%\Innovella\OneDrive
ROBOCOPY "%_source%\Users\shacterso\Desktop" "%_dest%\Users\shacterso\Desktop" %_what% %_exclude% %_log%

:DOCUMENTS
SET _exclude=/XD %_source%\Innovella\OneDrive
ROBOCOPY "%_source%\Users\shacterso\Documents" "%_dest%\Users\shacterso\Documents" %_what% %_exclude% %_log%


goto FINISH

:ONEDRIVE
SET _dest=\\%_remote%\Backups
ROBOCOPY "%_source%\Users\shacterso\OneDrive" "%_dest%\OneDrive" %_what% %_exclude% %_log%



:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
