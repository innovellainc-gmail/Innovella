"""
drive_mirror.py

Script to mirror (sync) a Google Drive / Shared Drive to an Innovella NAS backup folder.

Design notes:
- Uses rclone for robust Google Drive <> NAS syncing. rclone must be installed and configured with the Google account as a named remote.
- Prompts for: rclone remote name (represents the Google account), source path on that remote (shared drive name or folder path), destination path on the NAS (UNC or local path).
- Saves source/destination entries to drive_mirror_config.json for reuse.

Run examples:
  python drive_mirror.py               # interactive prompts
  python drive_mirror.py --use-saved   # use last saved source/destination
  python drive_mirror.py --dry-run     # show what would be synced (rclone --dry-run)

"""

import os
import sys
import json
import subprocess
import shutil
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / 'drive_mirror_config.json'


def load_config():
    if CONFIG_PATH.exists():
        try:
            return json.loads(CONFIG_PATH.read_text(encoding='utf-8'))
        except Exception:
            return {}
    return {}


def save_config(cfg):
    CONFIG_PATH.write_text(json.dumps(cfg, indent=2), encoding='utf-8')
    print(f"Saved configuration to {CONFIG_PATH}")


def check_rclone():
    return shutil.which('rclone') is not None


def run_rclone_sync(source, dest, dry_run=False):
    # Build rclone sync command. Using --progress so users can see output.
    cmd = ['rclone', 'sync', source, dest, '--progress', '--transfers', '4', '--checkers', '8']
    # Don't move to trash on Google Drive by default to avoid filling trash: user can change if desired
    cmd += ['--drive-use-trash=false']
    if dry_run:
        cmd.insert(2, '--dry-run')
    print('Running:', ' '.join(cmd))
    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError as e:
        print(f"rclone exited with code {e.returncode}")
        return False
    except FileNotFoundError:
        print('rclone executable not found. Ensure rclone is installed and on PATH.')
        return False
    return True


def prompt_input(prompt_text, default=None):
    if default:
        full = input(f"{prompt_text} [{default}]: ")
        return full.strip() or default
    else:
        return input(f"{prompt_text}: ").strip()


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Mirror a Google Drive / Shared Drive to a NAS using rclone')
    parser.add_argument('--use-saved', action='store_true', help='Use saved source/destination from last run')
    parser.add_argument('--save', action='store_true', help='Save the provided source/destination after prompting')
    parser.add_argument('--dry-run', action='store_true', help='Run rclone in --dry-run mode')
    parser.add_argument('--source', help='(Optional) Full rclone source path, e.g. gdrive:MyShare or gdrive:path/to/folder')
    parser.add_argument('--dest', help='(Optional) Destination path on NAS (UNC or local path)')
    args = parser.parse_args()

    cfg = load_config()

    if not check_rclone():
        print('\nERROR: rclone not found on PATH.\nInstall rclone (https://rclone.org/) and configure a Google Drive remote before using this script.\n')
        sys.exit(1)

    source = None
    dest = None
    remote = None

    if args.use_saved:
        if not cfg.get('source') or not cfg.get('dest'):
            print('No saved source/destination found in config. Will prompt for values.')
        else:
            source = cfg['source']
            dest = cfg['dest']
            print(f"Using saved source: {source}")
            print(f"Using saved destination: {dest}")

    # Accept CLI overrides first
    if args.source:
        source = args.source
    if args.dest:
        dest = args.dest

    # If source not provided, interactively prompt
    if not source:
        print('\nEnter Google account / source details:')
        print('This script expects an rclone remote name already configured for the Google account (for example "gdrive").')
        remote = prompt_input('Rclone remote name for Google account (e.g. gdrive)')
        if not remote:
            print('Remote name is required. Exiting.')
            sys.exit(1)

        print('\nFor the source on the remote, provide one of:\n  - a shared drive or folder name\n  - a path relative to the remote\nExamples:')
        print('  My Shared Drive')
        print('  folder/subfolder')
        print('  (Or use the shared drive ID if you prefer)')

        src_path = prompt_input('Source path on remote (leave empty to use root of remote)')
        if src_path:
            source = f"{remote}:{src_path}"
        else:
            source = f"{remote}:"

    # If destination not provided, prompt
    if not dest:
        print('\nEnter destination path on the NAS (UNC path or drive letter path).')
        dest = prompt_input('Destination path on NAS (e.g. \\NAS\\Backups\\gdrive or D:\\Backups\\gdrive)')
        if not dest:
            print('Destination path is required. Exiting.')
            sys.exit(1)

    # Confirm
    print('\nSummary:')
    print('  Source:', source)
    print('  Destination:', dest)
    ok = prompt_input('Proceed with sync? (yes/no)', default='no')
    if ok.lower() not in ('y', 'yes'):
        print('Aborted by user.')
        sys.exit(0)

    # Save if requested
    if args.save:
        cfg['source'] = source
        cfg['dest'] = dest
        save_config(cfg)
    else:
        # Offer to save interactively if different from saved config
        if cfg.get('source') != source or cfg.get('dest') != dest:
            save_choice = prompt_input('Save this source/destination for future runs? (yes/no)', default='yes')
            if save_choice.lower() in ('y', 'yes'):
                cfg['source'] = source
                cfg['dest'] = dest
                save_config(cfg)

    # Run rclone
    print('\nStarting sync... (this can take a long time depending on data size)')
    success = run_rclone_sync(source, dest, dry_run=args.dry_run)
    if success:
        print('\nSync completed successfully.')
    else:
        print('\nSync failed. See errors above.')


if __name__ == '__main__':
    main()
