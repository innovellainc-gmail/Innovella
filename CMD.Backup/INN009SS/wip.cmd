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
SET _exclude=/XD %_source%\DML
echo _host:	%_host%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

goto sfmc

:MRC
ROBOCOPY %_source%\SCHEMA %_dest%\3-Storage\MSSQL\MRC.DBO\01-SCHEMA %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOMAIN %_dest%\3-Storage\MSSQL\MRC.DBO\DOMAIN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\10-OBJECTS %_dest%\3-Storage\MSSQL\MRC.DBO\10-OBJECTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\20-CONFIG %_dest%\3-Storage\MSSQL\MRC.DBO\20-CONFIG %_what% %_exclude% %_logs%
ROBOCOPY %_source%\CONSTRAINTS %_dest%\3-Storage\MSSQL\MRC.DBO\CONSTRAINTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\PROCS %_dest%\3-Storage\MSSQL\MRC.DBO\PROCS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\TABLES %_dest%\3-Storage\MSSQL\MRC.DBO\TABLES %_what% %_exclude% %_logs%
ROBOCOPY %_source%\VIEWS %_dest%\3-Storage\MSSQL\MRC.DBO\VIEWS %_what% %_exclude% %_logs%
REM ROBOCOPY %_source%\PPT %_dest%\3-Storage\MSSQL\MRC.DBO\PPT %_what% %_exclude% %_logs%
REM ROBOCOPY %_source%\DOC %_dest%\3-Storage\MSSQL\MRC.DBO\DOCS %_what% %_exclude% %_logs%

:PILOT
ROBOCOPY %_source%\Pilot %_dest%\Pilot %_what% %_exclude% %_logs%

ROBOCOPY %_source%\DDL %_dest%\Pilot\00-DDL %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SCHEMA %_dest%\Pilot\01-SCHEMA %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOMAIN %_dest%\Pilot\02-DOMAIN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\TABLES %_dest%\Pilot\03-TABLES %_what% %_exclude% %_logs%
ROBOCOPY %_source%\CONSTRAINTS %_dest%\Pilot\04-CONSTRAINTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\VIEWS %_dest%\Pilot\05-VIEWS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\PROCS %_dest%\Pilot\06-PROCS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\10-OBJECTS %_dest%\Pilot\10-OBJECTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\20-CONFIG %_dest%\Pilot\20-CONFIG %_what% %_exclude% %_logs%
REM ROBOCOPY %_source%\DOC %_dest%\Pilot\07-DOCS %_what% %_exclude% %_logs%

:SFMC
ROBOCOPY %_source%\DDL %_dest%\SFMC\00-DDL %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SCHEMA %_dest%\SFMC\01-SCHEMA %_what% %_exclude% %_logs%
ROBOCOPY %_source%\DOMAIN %_dest%\SFMC\02-DOMAIN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\TABLES %_dest%\SFMC\03-TABLES %_what% %_exclude% %_logs%
ROBOCOPY %_source%\CONSTRAINTS %_dest%\SFMC\04-CONSTRAINTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\VIEWS %_dest%\SFMC\05-VIEWS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\PROCS %_dest%\SFMC\06-PROCS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\10-OBJECTS %_dest%\SFMC\10-OBJECTS %_what% %_exclude% %_logs%
ROBOCOPY %_source%\20-CONFIG %_dest%\SFMC\20-CONFIG %_what% %_exclude% %_logs%

ROBOCOPY %_source%\SFMC\DFD %_dest%\SFMC\DFD %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\DSD %_dest%\SFMC\DSD %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\ERD %_dest%\SFMC\ERD %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\FSD %_dest%\SFMC\FSD %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\PLN %_dest%\SFMC\PLN %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\SDD %_dest%\SFMC\SDD %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\STG %_dest%\SFMC\STG %_what% %_exclude% %_logs%
ROBOCOPY %_source%\SFMC\WHD %_dest%\SFMC\WHD %_what% %_exclude% %_logs%
REM ROBOCOPY %_source%\DOC %_dest%\SFMC\07-DOCS %_what% %_exclude% %_logs%

:FINISH
