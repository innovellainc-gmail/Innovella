@ECHO OFF
SETLOCAL
REM
REM	Mirror all OneDriveBurlington files to the NAS device.
REM	http://ss64.com/nt/robocopy.html
REM	https://technet.microsoft.com/en-us/magazine/2006.11.utilityspotlight.aspx
REM
REM	This command file to be executed from a single INNOVELLA device: INN009SS
REM	SOURCE:	\\INN009SS\C$:\Users\sshac\OneDrive - Burlington
REM	TARGET:	\\HQ1NAS01P01\Backups\OneDriveBurlington
REM
@ECHO OFF
SETLOCAL
REM SET /P _remote=Please enter the remote hostname/IP address (%_remote%): 
REM IF "%_remote%"=="" GOTO Error
REM SET _remote=HQ1NAS01P01
:DEFAULTS
SET _remote=172.16.1.51
SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _dest=\\%_remote%\Backups\OneDriveBurlington
REM
REM	Have to use pushd and popd to handle the UNC path for OneDrive
REM	pushd will create a virtual drive starting at Z: to map the UNC folders
REM	popd is used at the end to remove the temporary drive
REM
popd
pushd "\\%_local%\C$\Users\sshac\OneDrive - Burlington"
SET _source=Z:

SET _what=/MIR /E /COPY:DT /DCOPY:T /w:1 /r:1 /Z
SET _log=/LOG:"\\%_local%\C$\Backups\mir.OneDriveBurlington.txt" /FP /NS /NP /TEE
SET _logs=/LOG+:"\\%_local%\C$\Backups\mir.OneDriveBurlington.txt" /FP /NS /NP /TEE
SET _exclude=/XD "%_source%.eclipse" "%_source%Documents" "%_source%Software" "%_source%Apps" "%_source%Backups" "%_source%Dell"

echo _local:	%_local%
echo _source:	%_source%
echo _dest:	%_dest%
echo _what:	%_what%
echo _log:	%_log%
echo _logs:	%_logs%
echo _exclude:	%_exclude%
REM
REM	Mirror source files to \\HQ1NAS01P01\Backups\OneDriveBurlington folders.
REM	This next line sets up a share from host to remote. Sharenames don't us C$ on the remote!
REM	NET USE \\$_remote\IPC$ /u:$_username $_password
REM

:ONEDRIVE
ROBOCOPY %_source% %_dest% %_what% %_logs% %_exclude%

GOTO FINISH
:ERROR
ECHO Remote hostname or IP not entered!

:FINISH
REM	Remove the network share if it was created
REM	NET USE \\$_remote\IPC$ /D
popd


