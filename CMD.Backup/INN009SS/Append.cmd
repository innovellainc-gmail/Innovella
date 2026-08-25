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

:DEFAULTS
SET _remote=172.16.1.51
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$\Users\shacterso
SET _dest=\\%_local%\D$\Backups\%_local%\CDRIVE
SET _what=/IS /IT /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:\\%_local%\C$\Backups\local.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\local.txt /FP /NS /NP /TEE
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

goto repos

:DESKTOP
ROBOCOPY "%_source%\Desktop" "%_dest%\Desktop" %_what% %_log%

:PROJECTS
ROBOCOPY "%_source%\Workspaces\Projects" "%_dest%\Workspaces\Projects" %_what% %_log%

:REPOS
ROBOCOPY "%_source%\Workspaces\Repos" "%_dest%\Workspaces\Repos" %_what% %_log%

SET _source=\\%_local%\C$\LocalDrive
:DESKTOP
ROBOCOPY "%_source%\Desktop" "%_dest%\Desktop" %_what% %_log%
:MRC
ROBOCOPY "%_source%\MRC" "%_dest%\MRC" %_what% %_log%
:SOFTWARE
ROBOCOPY "%_source%\Software" "%_dest%\Software" %_what% %_log%

goto FINISH

:ERROR
ECHO Remote hostname or IP not entered!

:FINISH


