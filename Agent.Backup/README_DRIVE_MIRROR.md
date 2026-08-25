drive_mirror - Mirror a Google Drive / Shared Drive to a NAS using rclone (v2)

Overview
--------
This repository contains two scripts:
- drive_mirror.py (initial simple helper)
- drive_mirror_v2.py (recommended): improved version with multiple named profiles and non-interactive options

Both rely on rclone for reliable Google Drive <> NAS transfers.

Why rclone?
- rclone handles Google Drive authentication, rate limits, resumable transfers, and works well for large sets of files.
- It supports Google "shared drives" (team drives) and provides robust sync and copy semantics.

Prerequisites
-------------
1. Install rclone: https://rclone.org/install/
2. Configure an rclone remote for the Google account you want to use.

Quick rclone configuration (interactive):
  rclone config
  # follow prompts: n (new remote), give it a name (e.g. gdrive), choose 'drive', follow OAuth flow in browser

Non-interactive example (service-account or preconfigured):
- For production automated backups, prefer a service account with domain-wide delegation or a pre-authorized remote. See https://rclone.org/drive/#service-account for details.

Testing a dry-run sync
----------------------
After configuring an rclone remote named 'gdrive' (example), you can run a dry-run to preview:
  python drive_mirror_v2.py --profile mybackup --dry-run

If you don't yet have a profile, create one interactively:
  python drive_mirror_v2.py --create-profile mybackup

The --dry-run flag causes rclone to print planned actions without transferring data.

Profiles (drive_mirror_v2.py)
-----------------------------
Profiles are saved in drive_mirror_config.json under the 'profiles' key. Each profile contains:
  { "source": "gdrive:My Shared Drive", "dest": "\\NAS\\Backups\\mybackup", "description": "optional" }

Common operations:
  List profiles:    python drive_mirror_v2.py --list-profiles
  Create profile:   python drive_mirror_v2.py --create-profile mybackup
  Delete profile:   python drive_mirror_v2.py --delete-profile mybackup
  Run profile:      python drive_mirror_v2.py --profile mybackup
  Create and run:   python drive_mirror_v2.py --create-profile mybackup  # interactive create

Migration:
- If an older drive_mirror_config.json exists with top-level 'source'/'dest', drive_mirror_v2.py will migrate it to a 'default' profile automatically.

PowerShell helper: Scheduled Task creation
-----------------------------------------
A helper script create_scheduled_task.ps1 is included to create Windows Scheduled Tasks that run drive_mirror_v2.py.

Examples:
  # Daily at 02:00 as SYSTEM (no password required)
  .\create_scheduled_task.ps1 -TaskName "DriveMirrorDaily" -Profile "mybackup" -PythonPath "C:\\Python39\\python.exe" -ScriptPath "C:\\LocalDrive\\Repos\\Innovella\\InnovellaIncCMD\\drive_mirror_v2.py" -Daily -At "02:00"

  # Run every N minutes (useful for frequent incremental syncs)
  .\create_scheduled_task.ps1 -TaskName "DriveMirror6hr" -Profile "mybackup" -PythonPath "C:\\Python39\\python.exe" -ScriptPath "C:\\LocalDrive\\Repos\\Innovella\\InnovellaIncCMD\\drive_mirror_v2.py" -RepeatIntervalMinutes 360

Notes about scheduled tasks:
- The account used to run the task must have access to the destination NAS path. For UNC paths this can be a challenge — consider using a managed account with the proper credentials or mounting the NAS with a credential that the scheduled task can access.
- Test the profile manually (with --dry-run) before scheduling.

Security
--------
- The config file stores only profile metadata (source/destination strings). OAuth tokens and credentials remain in rclone's own config file (~/.config/rclone/rclone.conf or %APPDATA%\\rclone\\rclone.conf).
- Do not commit rclone.conf or credentials into source control.

Next steps / troubleshooting
---------------------------
- If rclone isn't on PATH, add it or provide the full path to the rclone executable in a wrapper.
- For large drives, test with --dry-run first and consider tuning rclone flags (--transfers, --checkers, --bwlimit).

Support
-------
If you need help configuring rclone or the Google Drive remote, consult https://rclone.org/drive/ or provide the exact error output for assistance.
