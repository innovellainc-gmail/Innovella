@ECHO OFF
SETLOCAL
:: mir.OneDrive.cmd
SET _appName=mir.OneDrive
SET _remote=HQ1NAS01P01
SET _local=%COMPUTERNAME%
SET _source=\\%_local%\C$\Users\sshac\OneDrive
SET _dest=\\%_remote%\Backups\OneDrive

REM 1. Strip Unnecessary Metadata Flags (The Most Common Fix)
REM If you are copying to a NAS or a Samba share, it may choke on specific Windows-only file attributes. Modify your Robocopy flags to only transfer data, attributes, and timestamps, rather than full NTFS security properties:
REM • Change /COPY:DATSOU or /COPYALL to /COPY:DAT
REM • Add /DCOPY:DAT (copies directory data and timestamps)
REM • Avoid using /B (backup mode) or /ZB unless explicitly required, as they alter network privilege tokens
REM 2. Lower or Disable Multi-Threading (/MT)
REM By default, modern Robocopy uses multi-threading. While /MT:32 or /MT:64 is great for local SSDs, it can overwhelm network buffers and SMB connections, triggering Error 59.
REM • Drop your thread count down using /MT:8 or /MT:4.
REM • If it continues to crash, remove the /MT flag entirely to run it in single-thread mode to establish a stable stream.
REM 3. Throttle Packet Size (Large Send Offload)
REM If the error occurs consistently around the exact same percentage of a huge file, your network card's hardware optimization might be crashing under the load. Turn off Large Send Offload (LSO) on your Windows machine:
REM  1. Right-click the Start menu and select Device Manager.
REM  2. Expand Network adapters and double-click your network card.
REM  3. Go to the Advanced tab.
REM  4. Scroll down to Large Send Offload v2 (IPv4) and change it to Disabled.
REM  5. Do the same for Large Send Offload v2 (IPv6) if it exists. Click OK. (Note: Your network will briefly disconnect for 2 seconds)
REM 4. Add Tolerant Retry Rules
REM By default, Robocopy will retry a failed file 1 million times, waiting 30 seconds between each attempt. If your network experiences a 1-second blip, Robocopy can pause the entire operation for a long time.
REM • Add /R:3 /W:5 to your script. This tells Robocopy to retry only 3 times and wait just 5 seconds before moving on, allowing the rest of your transfer to finish cleanly instead of freezing up
REM Yes, NS Offload (Neighbor Solicitation Offload) should definitely be checked, and in the case of network drops during massive file transfers, disabling it can help resolve the problem.
REM What is NS Offload?
REM NS Offload is an IPv6 networking feature. It offloads IPv6 Neighbor Solicitation requests (the IPv6 equivalent of IPv4's ARP) from your Windows operating system directly to the network interface card (NIC) hardware firmware.
REM When your PC is busy pushing heavy data via Robocopy, the NIC's onboard processor can get overwhelmed or experience firmware bugs. If the hardware mismanages or drops an NS request while handling massive traffic, the target server thinks your machine has temporarily dropped off the grid, instantly crashing the SMB session and triggering Error 59.

::Append the source to the destination
SET _what=/IS /IT /E /ZB /COPY:DT /DCOPY:T /w:1 /r:1 /Z
::Mirror the source to the destination
SET _what=/MIR /E /COPY:DAT /DCOPY:DAT /w:1 /r:1 /Z

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

:Workspaces
SET _src=%_source%\workspaces
SET _dst=%_dest%\workspaces
echo _src:	%_src%
echo _dst:	%_dest%
ROBOCOPY %_src% %_dst% %_what% %_logs% %_exclude%

goto finish
:Private
SET _src=%_source%\Private\Innovella
SET _dst=%_dest%\Private\Innovella
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

