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

set _host=%COMPUTERNAME%
SET _source=\\%_host%\C$
SET _dest=\\NASINC\Backups\%_host%\HOME\CDRIVE
SET _what=/MIR /COPY:DT /DCOPY:T /Z
SET _log=/LOG:\\%_host%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_host%\C$\Backups\inn.log.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\Innovella\OneDrive %_source%\Innovella\OOSQL.v4\Artifacts %_source%\Innovella\OOSQL.v4\Reference %_source%\Innovella\OOSQL.v4\IMG

echo _host:	%_host%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

goto FINISH


:EVENTS
ROBOCOPY %_source%\Events %_dest%\Events %_what%

:INNOVELLA
ROBOCOPY %_source%\Innovella\Backups %_dest%\Innovella\Backups %_what% %_exclude%
ROBOCOPY %_source%\Innovella\Clients %_dest%\Innovella\Clients %_what% %_exclude%
ROBOCOPY %_source%\Innovella\Notes %_dest%\Innovella\Notes %_what% %_exclude%
ROBOCOPY %_source%\Innovella\OOSQL.v4 %_dest%\Innovella\OOSQL.v4 %_what% %_exclude%

goto downloads

SET _source=\\%_host%\C$\www\lsg
SET _dest=\\NASINC\Backups\%_host%\HOME\CDRIVE\www\lsg
SET _exclude=/XD \\%_host%\C$\www\pds\wip\PICS \\%_host%\C$\www\pds\local\CPS \\%_host%\C$\www\pds\local\eAudit \\%_host%\C$\www\pds\wip\OODSL\.git
ROBOCOPY %_source%\live %_dest%\live %_what% %_exclude% %_logs%
ROBOCOPY %_source%\local %_dest%\local %_what% %_exclude% %_logs%
ROBOCOPY %_source%\rel %_dest%\rel %_what% %_exclude% %_logs%

:DOWNLOADS
SET _exclude=/XA:SH
ROBOCOPY %_source%\Users\shacter\Downloads %_dest%\Downloads /XO

:FINISH
