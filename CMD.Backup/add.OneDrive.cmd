@ECHO OFF
SETLOCAL
:: add.OneDrive.cmd
SET _appName=add.OneDrive
SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$\Users\sshac\OneDrive
SET _dest=\\%_remote%\Backups\OneDrive

::Mirror the source to the destination
SET _what=/MIR /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
::Append the source to the destination
SET _what=/IS /IT /E /ZB /COPY:DT /DCOPY:T /w:1 /r:1 /Z

REM What This Command Does/E: Copies all subdirectories, including empty ones.
REM /ZB: Uses restartable mode; if access is denied, it switches to backup mode.
REM /R:3 and /W:5: Retries locked files 3 times, waiting 5 seconds between attempts.
REM /XF *.gslides *.gdoc ...: Crucial Step. This tells Robocopy to completely skip the web shortcuts that cause the "Incorrect function" error.

SET _log=/LOG:"\\%_local%\C$\LocalDrive\Logs\%_appName%.log.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\LocalDrive\Logs\%_appName%.log.txt" /FP /NS /NP /TEE
SET _exclude=/XD "%_source%\Apps" "%_source%\Backups" "%_source%\Dell"
SET _exclude=/XF *.gsheet *.gslides *.gdoc *.gform *.gmap *.gsite

echo _appName:	%_appName%
echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

:Documents
SET _src=%_source%\Desktop
SET _dst=%_dest%\Desktop
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src=%_source%\Documents\Autosave
SET _dst=%_dest%\Documents\Autosave
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src="%_source%\Documents\Outlook Files"
SET _dst="%_dest%\Documents\OutlookFiles"
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src=%_source%\Documents\PowerShell
SET _dst=%_dest%\Documents\PowerShell
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src="%_source%\Microsoft Edge Collections"
SET _dst="%_dest%\MicrosoftEdgeCollections"
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

:Pictures
SET _src=%_source%\Pictures\Family
SET _dst=%_dest%\Pictures\Family
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src=%_source%\Pictures\iCloud
SET _dst=%_dest%\Pictures\iCloud
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

SET _src="%_source%\Pictures\Screenshots 1"
SET _dst="%_dest%\Pictures\Screenshots"
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D

