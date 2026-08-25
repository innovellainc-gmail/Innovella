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

REM	"C:\Users\shacterso\Workspaces\Repos\PDS\EDEM\CHIP\3-Storage\MSSQL\MRC.DBO"
set _host=%COMPUTERNAME%
SET _source=\\%_host%\C$\LocalDrive\CHIP
SET _dest=\\%_host%\C$\Users\shacterso\Workspaces\Repos\PDS\EDEM\CHIP
SET _what=/MIR /COPY:DT /DCOPY:T /Z
SET _log=/LOG:\\%_host%\C$\Backups\wip.log.txt /FP /NS /NP /TEE
SET _logs=/LOG+:\\%_host%\C$\Backups\wip.log.txt /FP /NS /NP /TEE
SET _exclude=/XD %_source%\DML %_source%\Pilot
echo _host:	%_host%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

:MRC
ROBOCOPY %_source%\SCHEMA %_dest%\3-Storage\MSSQL\MRC.DBO\01-SCHEMA %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOMAIN %_dest%\3-Storage\MSSQL\MRC.DBO\DOMAIN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\10-OBJECTS %_dest%\3-Storage\MSSQL\MRC.DBO\10-OBJECTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\20-CONFIG %_dest%\3-Storage\MSSQL\MRC.DBO\20-CONFIG %_what% %_exclude% %_logs%
ROBOCOPY %_source%\CONSTRAINTS %_dest%\3-Storage\MSSQL\MRC.DBO\CONSTRAINTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\PROCS %_dest%\3-Storage\MSSQL\MRC.DBO\PROCS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\TABLES %_dest%\3-Storage\MSSQL\MRC.DBO\TABLES %_what% %_exclude% %_logs%
ROBOCOPY %_source%\VIEWS %_dest%\3-Storage\MSSQL\MRC.DBO\VIEWS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOC %_dest%\3-Storage\MSSQL\MRC.DBO\DOCS %_what% %_exclude% %_logs%

:PILOT
ROBOCOPY %_source%\DDL %_dest%\Pilot\00-DDL %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SCHEMA %_dest%\Pilot\01-SCHEMA %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOMAIN %_dest%\Pilot\02-DOMAIN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\TABLES %_dest%\Pilot\03-TABLES %_what% %_exclude% %_logs%
ROBOCOPY %_source%\CONSTRAINTS %_dest%\Pilot\04-CONSTRAINTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\VIEWS %_dest%\Pilot\05-VIEWS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\PROCS %_dest%\Pilot\06-PROCS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\10-OBJECTS %_dest%\Pilot\10-OBJECTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\20-CONFIG %_dest%\Pilot\20-CONFIG %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOC %_dest%\Pilot\07-DOCS %_what% %_exclude% %_logs%

:FINISH
