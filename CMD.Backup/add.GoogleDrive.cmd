@ECHO OFF
SETLOCAL

SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _dest=\\%_remote%\Backups\GoogleDrive
SET _source=\\%_local%\H$

::Mirror the source to the destination
SET _what=/MIR /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
::Append the source to the destination
SET _what=/IS /IT /E /ZB /COPY:DT /DCOPY:T /w:1 /r:1 /Z

REM What This Command Does/E: Copies all subdirectories, including empty ones.
REM /ZB: Uses restartable mode; if access is denied, it switches to backup mode.
REM /R:3 and /W:5: Retries locked files 3 times, waiting 5 seconds between attempts.
REM /XF *.gslides *.gdoc ...: Crucial Step. This tells Robocopy to completely skip the web shortcuts that cause the "Incorrect function" error.

SET _log=/LOG:"\\%_local%\C$\LocalDrive\Logs\add.GoogleDrive.log.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\LocalDrive\Logs\add.GoogleDrive.log.txt" /FP /NS /NP /TEE
SET _exclude=/XD "%_source%\Apps" "%_source%\Backups" "%_source%\Dell"
SET _exclude=/XF *.gsheet *.gslides *.gdoc *.gform *.gmap *.gsite

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

:H-sol.shacter
SET _source="H:\My Drive"
SET _dest=%_dest%\sol.shacter\MyDrive
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

SET _source="H:\Other computers"
SET _dest=%_dest%\sol.shacter\MyLaptop
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D

