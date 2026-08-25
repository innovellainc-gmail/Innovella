"""
drive_mirror_v2.py

Improved version of drive_mirror with multi-profile support.
See README_DRIVE_MIRROR.md for usage and scheduler helper.
"""

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
            data = json.loads(CONFIG_PATH.read_text(encoding='utf-8'))
            if isinstance(data, dict) and ('source' in data or 'dest' in data) and 'profiles' not in data:
                profiles = {}
                profiles['default'] = {
                    'source': data.get('source', ''),
                    'dest': data.get('dest', ''),
                    'description': data.get('description', 'migrated default profile')
                }
                data = {'profiles': profiles}
                save_config(data)
            if 'profiles' not in data:
                data = {'profiles': {}}
            return data
        except Exception:
            return {'profiles': {}}
    return {'profiles': {}}


def save_config(cfg):
    CONFIG_PATH.write_text(json.dumps(cfg, indent=2), encoding='utf-8')
    print(f"Saved configuration to {CONFIG_PATH}")


def check_rclone():
    return shutil.which('rclone') is not None


def run_rclone_sync(source, dest, dry_run=False):
    cmd = ['rclone', 'sync']
    if dry_run:
        cmd.append('--dry-run')
    cmd += [source, dest, '--progress', '--transfers', '4', '--checkers', '8', '--drive-use-trash=false']
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


def list_profiles(cfg):
    profiles = cfg.get('profiles', {})
    if not profiles:
        print('No profiles configured.')
        return
    print('Configured profiles:')
    for name, p in profiles.items():
        desc = p.get('description', '')
        print(f"  {name}: source={p.get('source','')} dest={p.get('dest','')} {('- '+desc) if desc else ''}")


def create_profile_interactive(cfg, name=None):
    if not name:
        name = prompt_input('Profile name (unique)')
    if not name:
        print('Profile name required.')
        return None
    if name in cfg.get('profiles', {}):
        print(f"Profile '{name}' already exists.")
        return None
    print('\nEnter Google account / source details:')
    print('This script expects an rclone remote name already configured for the Google account (for example "gdrive").')
    remote = prompt_input('Rclone remote name for Google account (e.g. gdrive)')
    if not remote:
        print('Remote name is required. Aborting profile creation.')
        return None
    src_path = prompt_input('Source path on remote (leave empty to use root of remote)')
    if src_path:
        source = f"{remote}:{src_path}"
    else:
        source = f"{remote}:"
    dest = prompt_input('Destination path on NAS (e.g. \\NAS\\Backups\\gdrive or D:\\Backups\\gdrive)')
    if not dest:
        print('Destination path is required. Aborting profile creation.')
        return None
    desc = prompt_input('Optional description for this profile', default='')
    cfg.setdefault('profiles', {})[name] = {'source': source, 'dest': dest, 'description': desc}
    save_config(cfg)
    print(f"Created profile '{name}'")
    return name


def delete_profile(cfg, name):
    if name not in cfg.get('profiles', {}):
        print(f"Profile '{name}' not found.")
        return False
    confirm = prompt_input(f"Delete profile '{name}'? (yes/no)", default='no')
    if confirm.lower() in ('y', 'yes'):
        del cfg['profiles'][name]
        save_config(cfg)
        print(f"Deleted profile '{name}'")
        return True
    print('Delete cancelled')
    return False


def select_profile(cfg, name=None, use_saved=False):
    profiles = cfg.get('profiles', {})
    if name:
        if name not in profiles:
            print(f"Profile '{name}' does not exist.")
            return None
        return name
    if use_saved and 'default' in profiles:
        return 'default'
    if len(profiles) == 1:
        return next(iter(profiles))
    if not profiles:
        return None
    print('Available profiles:')
    for i, key in enumerate(profiles.keys(), start=1):
        print(f"  {i}) {key}")
    choice = prompt_input('Select profile by number or name')
    if not choice:
        return None
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(profiles):
            return list(profiles.keys())[idx]
        else:
            print('Invalid selection')
            return None
    if choice in profiles:
        return choice
    print('Invalid selection')
    return None


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Mirror a Google Drive / Shared Drive to a NAS using rclone')
    parser.add_argument('--list-profiles', action='store_true', help='List configured profiles')
    parser.add_argument('--create-profile', nargs='?', const='', help='Create a new profile (optionally provide name)')
    parser.add_argument('--delete-profile', help='Delete the named profile')
    parser.add_argument('--profile', help='Use the named profile')
    parser.add_argument('--use-saved', action='store_true', help='Use default profile if present')
    parser.add_argument('--save', action='store_true', help='Save provided source/destination after prompting (creates/overwrites profile)')
    parser.add_argument('--dry-run', action='store_true', help='Run rclone in --dry-run mode')
    parser.add_argument('--source', help='(Optional) Full rclone source path, e.g. gdrive:MyShare or gdrive:path/to/folder')
    parser.add_argument('--dest', help='(Optional) Destination path on NAS (UNC or local path)')
    args = parser.parse_args()

    cfg = load_config()

    if args.list_profiles:
        list_profiles(cfg)
        return
    if args.delete_profile:
        delete_profile(cfg, args.delete_profile)
        return
    if args.create_profile is not None:
        name = args.create_profile or None
        create_profile_interactive(cfg, name=name)
        return

    if not check_rclone():
        print('\nERROR: rclone not found on PATH.\nInstall rclone (https://rclone.org/) and configure a Google Drive remote before using this script.\n')
        sys.exit(1)

    profile_name = None

    if args.profile:
        profile_name = args.profile
        if profile_name not in cfg.get('profiles', {}):
            print(f"Profile '{profile_name}' not found.\nUse --list-profiles to see available profiles or --create-profile to make one.")
            sys.exit(1)
    else:
        profile_name = select_profile(cfg, name=None, use_saved=args.use_saved)

    source = None
    dest = None

    if args.source:
        source = args.source
    if args.dest:
        dest = args.dest

    if profile_name and not source and not dest:
        profile = cfg['profiles'].get(profile_name, {})
        source = profile.get('source')
        dest = profile.get('dest')
        print(f"Using profile '{profile_name}': source={source} dest={dest}")

    if not source:
        print('\nEnter Google account / source details:')
        print('This script expects an rclone remote name already configured for the Google account (for example "gdrive").')
        remote = prompt_input('Rclone remote name for Google account (e.g. gdrive)')
        if not remote:
            print('Remote name is required. Exiting.')
            sys.exit(1)
        src_path = prompt_input('Source path on remote (leave empty to use root of remote)')
        if src_path:
            source = f"{remote}:{src_path}"
        else:
            source = f"{remote}:"

    if not dest:
        print('\nEnter destination path on the NAS (UNC path or drive letter path).')
        dest = prompt_input('Destination path on NAS (e.g. \\NAS\\Backups\\gdrive or D:\\Backups\\gdrive)')
        if not dest:
            print('Destination path is required. Exiting.')
            sys.exit(1)

    print('\nSummary:')
    print('  Source:', source)
    print('  Destination:', dest)
    proceed = prompt_input('Proceed with sync? (yes/no)', default='no')
    if proceed.lower() not in ('y', 'yes'):
        print('Aborted by user.')
        sys.exit(0)

    if args.save:
        if not profile_name:
            profile_name = prompt_input('Name for profile to save (unique)')
            if not profile_name:
                print('Profile name required to save. Skipping save.')
                profile_name = None
        if profile_name:
            cfg.setdefault('profiles', {})[profile_name] = {'source': source, 'dest': dest, 'description': ''}
            save_config(cfg)
    else:
        if profile_name:
            existing = cfg['profiles'].get(profile_name, {})
            if existing.get('source') != source or existing.get('dest') != dest:
                save_choice = prompt_input('Save this source/destination to the selected profile? (yes/no)', default='yes')
                if save_choice.lower() in ('y', 'yes'):
                    cfg.setdefault('profiles', {})[profile_name] = {'source': source, 'dest': dest, 'description': existing.get('description','')}
                    save_config(cfg)
        else:
            if cfg.get('profiles'):
                save_choice = prompt_input('Save this source/destination as a new profile? (yes/no)', default='yes')
                if save_choice.lower() in ('y', 'yes'):
                    new_name = prompt_input('Name for new profile')
                    if new_name:
                        cfg.setdefault('profiles', {})[new_name] = {'source': source, 'dest': dest, 'description': ''}
                        save_config(cfg)

    print('\nStarting sync... (this can take a long time depending on data size)')
    success = run_rclone_sync(source, dest, dry_run=args.dry_run)
    if success:
        print('\nSync completed successfully.')
    else:
        print('\nSync failed. See errors above.')


if __name__ == '__main__':
    main()
