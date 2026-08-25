<#
create_scheduled_task.ps1

PowerShell helper to create a Windows Scheduled Task that runs drive_mirror_v2.py with a named profile.

Usage examples:
  # Create a daily task at 02:00 running as SYSTEM (no interactive session)
  .\create_scheduled_task.ps1 -TaskName "DriveMirrorDaily" -Profile "mybackup" -PythonPath "C:\Python39\python.exe" -ScriptPath "C:\LocalDrive\Repos\Innovella\InnovellaIncCMD\drive_mirror_v2.py" -Daily -At "02:00"

  # Create a task that runs every 6 hours
  .\create_scheduled_task.ps1 -TaskName "DriveMirror6hr" -Profile "mybackup" -PythonPath "C:\Python39\python.exe" -ScriptPath "C:\LocalDrive\Repos\Innovella\InnovellaIncCMD\drive_mirror_v2.py" -RepeatIntervalMinutes 360

Notes:
- The account specified must have access to the destination NAS path, or run as SYSTEM if the NAS is accessible that way.
- The script uses schtasks.exe to create tasks which is broadly compatible across Windows versions.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskName,

    [Parameter(Mandatory=$true)]
    [string]$Profile,

    [Parameter(Mandatory=$true)]
    [string]$PythonPath,

    [Parameter(Mandatory=$true)]
    [string]$ScriptPath,

    [switch]$Daily,
    [string]$At = "02:00",
    [int]$RepeatIntervalMinutes = 0,

    [string]$User = "SYSTEM",
    [string]$Password = "",

    [switch]$RunOnce,
    [switch]$Force
n)

# Build action
$actionArgs = "`"$ScriptPath`" --profile `"$Profile`" --use-saved"
$action = "`"$PythonPath`" $actionArgs"

if ($Daily) {
    $trigger = "/SC DAILY /ST $At"
} elseif ($RunOnce) {
    # Run once now
    $now = Get-Date
    $st = $now.AddMinutes(1).ToString('HH:mm')
    $trigger = "/SC ONCE /ST $st"
} elseif ($RepeatIntervalMinutes -gt 0) {
    # Use minute schedule with repeat interval
    # Create a schedule that runs every $RepeatIntervalMinutes minutes starting now
    $trigger = "/SC MINUTE /MO $RepeatIntervalMinutes"
} else {
    # Default: daily at specified time
    $trigger = "/SC DAILY /ST $At"
}

# Build schtasks command
$taskCmd = "schtasks /Create /TN `"$TaskName`" $trigger /TR `"$action`" /F"

if ($User -and $User -ne 'SYSTEM') {
    if (-not $Password) {
        Write-Host "Creating task for user $User; password not provided, schtasks will prompt if required."
        $taskCmd = "schtasks /Create /TN `"$TaskName`" $trigger /TR `"$action`" /RU `"$User`" /F"
    } else {
        $taskCmd = "schtasks /Create /TN `"$TaskName`" $trigger /TR `"$action`" /RU `"$User`" /RP `"$Password`" /F"
    }
}

Write-Host "Creating scheduled task with command:" -ForegroundColor Cyan
Write-Host $taskCmd

if ($Force) {
    cmd.exe /c $taskCmd
} else {
    $resp = Read-Host "Proceed to create task? (yes/no) [no]"
    if ($resp -in @('y','Y','yes','Yes')) {
        cmd.exe /c $taskCmd
    } else {
        Write-Host "Cancelled by user."
    }
}
