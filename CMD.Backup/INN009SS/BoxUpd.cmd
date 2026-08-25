@ECHO OFF
SETLOCAL

REM	SaveToBox.cmd
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM	https://technet.microsoft.com/en-us/magazine/2009.04.utilityspotlight.aspx
REM
REM

@ECHO OFF
SETLOCAL

:DEFAULTS
SET _remote=%COMPUTERNAME%
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$
SET _dest=\\%_remote%\C$
SET _what=/MIR /COPY:DT /DCOPY:T /Z
SET _log=/LOG:\\%_local%\C$\Backups\box.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_local%\C$\Backups\log.BOX.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\Applications %_source%\AWS %_source%\Backups %_source%\Software %_source%\Temp

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

rem C:\Users\shacterso\OneDrive\workspaces\Projects
rem C:\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive


:AWS
ROBOCOPY "%_source%\AWS" "%_dest%\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive\AWS" %_what% %_log%

:LOCALDRIVE
ROBOCOPY "%_source%\LocalDrive" "%_dest%\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive\LocalDrive" %_what% %_log%

:EDW
ROBOCOPY "%_source%\Users\shacterso\OneDrive\workspaces\Projects\PDS\05.EDW" "%_dest%\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive\Projects\PDS\05.EDW" %_what% %_log%

goto REPOS

:PROJECTS
ROBOCOPY "%_source%\Users\shacterso\OneDrive\workspaces\Projects" "%_dest%\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive\Projects" %_what% %_log%

:REPOS
SET _source=\\%_local%\C$\Users\shacterso\OneDrive\workspaces\Repos\PDS\EDW
SET _dest=\\%_remote%\C$\Users\shacterso\Box\shacterso@pacificdentalservices.com\New H Drive\Repos\PDS\EDW

SET _exclude=/XD %_source%\BIR\.git
ROBOCOPY "%_source%\BIR" "%_dest%\BIR" %_what% %_logs%

SET _exclude=/XD %_source%\ETL\.git
ROBOCOPY "%_source%\BIR" "%_dest%\ETL" %_what% %_logs%

SET _exclude=/XD %_source%\MRC\.git
ROBOCOPY "%_source%\BIR" "%_dest%\MRC" %_what% %_logs%

goto FINISH

SET _source=\\%_local%\C$\www\lsg
SET _dest=\\%_remote%\Backups\%_local%\HOME\CDRIVE\www\lsg
SET _exclude=/XD \\%_local%\C$\www\pds\wip\PICS \\%_local%\C$\www\pds\local\CPS \\%_local%\C$\www\pds\local\eAudit \\%_local%\C$\www\pds\wip\OODSL\.git
ROBOCOPY %_source%\live %_dest%\live %_what% %_exclude% %_logs%
ROBOCOPY %_source%\local %_dest%\local %_what% %_exclude% %_logs%
ROBOCOPY %_source%\rel %_dest%\rel %_what% %_exclude% %_logs%

:DOWNLOADS
SET _exclude=/XA:SH
ROBOCOPY %_source%\Users\shacter\Downloads %_dest%\Downloads /XO

:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
