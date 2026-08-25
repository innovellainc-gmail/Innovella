@ECHO OFF
SETLOCAL

REM
REM 	FROM:	IT-559L-NJ\C$\Users\sshacter\OneDrive - Burlington
REM				C:\Users\sshac\OneDrive - Burlington
REM 	TO:	\\HQ1NAS01P01\Backups\IT-559L-NJ\CDRIVE\Users\sshacter\OneDriveBurlington
REM

@ECHO OFF
SETLOCAL

:DEFAULTS
SET _remote=172.16.1.51
SET _remote=192.168.102.141

SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _dest=\\HQ1NAS01P01\Backups\IT-559L-NJ\CDRIVE\Users\sshacter\OneDriveBurlington
REM		   \\HQ1NAS01P01\Backups\IT-559L-NJ\CDRIVE\Users\sshacter\OneDriveBurlington
REM
REM	Have to use pushd and popd to handle the UNC path for OneDrive
REM	pushd will create a virtual drive starting at Z: to map the UNC folders
REM	popd is used at the end to remove the temporary drive
REM
popd
pushd "\\%_local%\C$\Users\sshac\OneDrive - Burlington"
SET _source=Z:

SET _what=/MIR /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:"\\%_local%\C$\Backups\Burlington.log.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\Backups\Burlington.log.txt" /FP /NS /NP /TEE
SET _exclude=/XD "%_source%Documents" "%_source%Apps" "%_source%Backups" "%_source%Dell"

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%

REM	This next line sets up a share from host to remote. Sharenames don't us C$ on the remote!
REM	NET USE \\$_remote\IPC$ /u:$_username $_password

:ONEDRIVE
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%


goto finish


:INNOVELLA
SET _source=%_source%Workspaces\Projects\Burlington
SET _dest=\\%_local%\C$\Users\Sshacter\OneDrive\workspaces\Projects\Burlington
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

popd
pushd "\\%_local%\C$\Users\sshacter\OneDrive - Burlington\Documents - Merchant and Planning 2.0"
SET _source=Z:

SET _dest=\\%_local%\C$\Users\Sshacter\OneDrive\workspaces\Projects\Burlington\Intranet\MerchantPlanning
echo _source:	%_source%
echo _dest:	%_dest%
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D
popd

