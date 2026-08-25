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
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$
SET _dest=\\%_remote%\Backups\%_local%\CDRIVE
SET _what=/MIR /COPY:DT /DCOPY:T /Z
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

REM
REM	Update (mirror) source files to \\HQ1NAS01P01\Backups\OneDrive folders only.
REM	Uses the mirror command so files and folders mirror the source machine.
REM

:LOCALDRIVE
ROBOCOPY "%_source%\LocalDrive" "%_dest%\LocalDrive" %_what% %_log%

goto onedrive

:AWS
ROBOCOPY "%_source%\AWS" "%_dest%\AWS" %_what% %_log%

:REGEDITS
ROBOCOPY %_source%\Regedits %_dest%\Regedits %_what%

:TEMP
ROBOCOPY "%_source%\Temp" "%_dest%\Temp" %_what% %_log%

:DOWNLOADS
SET _exclude=/XA:SH
ROBOCOPY %_source%\Users\shacterso\Downloads %_dest%\Users\shacterso\Downloads /XO

:ONEDRIVE
SET _dest=\\%_remote%\Backups\%_local%\
ROBOCOPY "%_source%\Users\shacterso\OneDrive" "%_dest%\OneDrive" %_what% %_log%


goto FINISH

:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
