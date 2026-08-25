@ECHO OFF
SETLOCAL

REM
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM	https://technet.microsoft.com/en-us/magazine/2009.04.utilityspotlight.aspx
REM
REM	The following URL is for another utility called RichCopy
REM	https://docs.microsoft.com/en-us/previous-versions/technet-magazine/dd547088(v=msdn.10)
REM

@ECHO OFF
SETLOCAL
REM SET /P _remote=Please enter the remote hostname/IP address (%_remote%): 
REM IF "%_remote%"=="" GOTO Error
REM SET _remote=HQ1NAS01P01

:DEFAULTS
SET _remote=172.16.1.51
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$\Users\shacterso\OneDrive
SET _dest=\\%_remote%\Backups\OneDrive
SET _what=/IS /IT /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:\\%_local%\C$\Backups\inn.1drive.txt /FP /NS /NP /TEE
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
REM	Add source files to \\HQ1NAS01P01\Backups\OneDrive folders only.
REM	Does not use the mirror command so no files are erased.
REM

:DESKTOP
ROBOCOPY "%_source%\Desktop" "%_dest%\Desktop" %_what% %_log%

:PRIVATE
ROBOCOPY "%_source%\Private" "%_dest%\Private" %_what% %_log%

:PUBLIC
ROBOCOPY "%_source%\Public" "%_dest%\Public" %_what% %_log%

:SOFTWARE
ROBOCOPY "%_source%\Software" "%_dest%\Software" %_what% %_log%

:WORKSPACES
ROBOCOPY "%_source%\workspaces" "%_dest%\Workspaces" %_what% /R:0 /W:0 %_log%

goto FINISH

:ERROR
ECHO Remote hostname or IP not entered!

:FINISH


