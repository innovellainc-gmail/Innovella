"""
drive_mirror_local.py

Local mirroring agent: mirrors a source folder (mounted Google Drive or local drive letter) to a destination folder (NAS drive letter or UNC path).

Features:
- Multiple named profiles stored in drive_mirror_config.json under 'profiles'.
- Interactive and non-interactive profile management: --list-profiles, --create-profile, --delete-profile
- Mirror behavior: copy new/changed files, optional deletion of extraneous files in destination (default: delete to keep mirror)
- Dry-run mode shows planned actions without modifying files
- Uses only Python standard library (no rclone)

Usage examples:
  python drive_mirror_local.py --create-profile mybackup
  python drive_mirror_local.py --profile mybackup --dry-run
  python drive_mirror_local.py --profile mybackup
  python drive_mirror_local.py --profile mybackup --no-delete

"""

import sys
import json
import shutil
import os
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = SCRIPT_DIR / 'drive_mirror_config.json'


def load_config():
    if CONFIG_PATH.exists():
        try:
            data = json.loads(CONFIG_PATH.read_text(encoding='utf-8'))
            # Migrate old top-level source/dest to default profile
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


def prompt_input(prompt_text, default=None):
    if default is not None:
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
    print('\nEnter source and destination local paths (drive letters or UNC paths).')
    src = prompt_input('Source path (e.g. G:\\ or G:\\Shared Drive\\Folder)')
    if not src:
        print('Source path required. Aborting profile creation.')
        return None
    dst = prompt_input('Destination path on NAS (e.g. \\NAS\\Backups\\gdrive or D:\\Backups\\gdrive)')
    if not dst:
        print('Destination path required. Aborting profile creation.')
        return None
    desc = prompt_input('Optional description for this profile', default='')
    cfg.setdefault('profiles', {})[name] = {'source': src, 'dest': dst, 'description': desc}
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


def is_local_path(path_str):
    # Accept drive-letter paths like 'G:\' or UNC like '\\NAS\\Share'
    if not path_str:
        return False
    p = Path(path_str)
    try:
        # Path.is_absolute works for both UNC and drive-letter
        return p.is_absolute()
    except Exception:
        return False


def ensure_dir(path, dry_run=False):
    if dry_run:
        if not Path(path).exists():
            print(f"[DRY-RUN] Would create directory: {path}")
        return
    Path(path).mkdir(parents=True, exist_ok=True)


def file_checksum(path, algorithm='md5'):
    import hashlib
    h = hashlib.new(algorithm)
    try:
        with open(path, 'rb') as f:
            while True:
                chunk = f.read(8 * 1024 * 1024)
                if not chunk:
                    break
                h.update(chunk)
        return h.hexdigest()
    except Exception:
        return None


def copy_file_atomic(src_path, dst_path, dry_run=False, retries=3, wait=5):
    src = Path(src_path)
    dst = Path(dst_path)
    dst_parent = dst.parent
    if not dst_parent.exists():
        if dry_run:
            print(f"[DRY-RUN] Would create directory: {dst_parent}")
        else:
            try:
                dst_parent.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                print(f"Error creating directory {dst_parent}: {e}")
                return False

    if dry_run:
        print(f"[DRY-RUN] Would copy: {src} -> {dst}")
        return True

    tmp = dst.with_suffix('.tmp_copy')
    attempt = 0
    while attempt <= retries:
        attempt += 1
        try:
            shutil.copy2(src, tmp)
            os.replace(tmp, dst)
            return True
        except Exception as e:
            print(f"Attempt {attempt}/{retries+1} - Error copying {src} -> {dst}: {e}")
            try:
                if tmp.exists():
                    tmp.unlink()
            except Exception:
                pass
            if attempt > retries:
                print(f"Giving up copying {src}")
                return False
            else:
                time.sleep(wait)
    return False


def mirror_directory(src_root, dst_root, dry_run=False, delete_extra=True, retries=3, wait=5, checksum=False, time_tolerance=1):
    src_root = Path(src_root)
    dst_root = Path(dst_root)
    if not src_root.exists():
        print(f"Source path does not exist: {src_root}")
        return False
    ensure_dir(dst_root, dry_run=dry_run)

    copied = 0
    skipped = 0
    errors = 0

    # Walk source
    for dirpath, dirnames, filenames in os.walk(src_root):
        rel_dir = os.path.relpath(dirpath, src_root)
        if rel_dir == '.':
            rel_dir = ''
        dst_dir = dst_root.joinpath(rel_dir)
        ensure_dir(dst_dir, dry_run=dry_run)
        for fname in filenames:
            sfile = Path(dirpath) / fname
            dfile = dst_dir / fname
            try:
                if not dfile.exists():
                    ok = copy_file_atomic(sfile, dfile, dry_run=dry_run, retries=retries, wait=wait)
                    if ok:
                        copied += 1
                    else:
                        errors += 1
                else:
                    need_copy = False
                    try:
                        s_stat = sfile.stat()
                        d_stat = dfile.stat()
                        if checksum:
                            s_sum = file_checksum(sfile)
                            d_sum = file_checksum(dfile)
                            if s_sum is None or d_sum is None or s_sum != d_sum:
                                need_copy = True
                        else:
                            if s_stat.st_size != d_stat.st_size:
                                need_copy = True
                            else:
                                # allow a tolerance for timestamp differences
                                if abs(s_stat.st_mtime - d_stat.st_mtime) > time_tolerance:
                                    need_copy = True
                    except Exception as e:
                        print(f"Error stat/checksum for {sfile} or {dfile}: {e}")
                        need_copy = True

                    if need_copy:
                        ok = copy_file_atomic(sfile, dfile, dry_run=dry_run, retries=retries, wait=wait)
                        if ok:
                            copied += 1
                        else:
                            errors += 1
                    else:
                        skipped += 1
            except Exception as e:
                print(f"Error processing file {sfile}: {e}")
                errors += 1

    # Delete extras in destination not present in source
    deleted = 0
    if delete_extra:
        for dirpath, dirnames, filenames in os.walk(dst_root, topdown=False):
            rel_dir = os.path.relpath(dirpath, dst_root)
            if rel_dir == '.':
                rel_dir = ''
            s_dir = src_root.joinpath(rel_dir)
            # Files
            for fname in filenames:
                dfile = Path(dirpath) / fname
                sfile = s_dir / fname
                if not sfile.exists():
                    if dry_run:
                        print(f"[DRY-RUN] Would delete: {dfile}")
                        deleted += 1
                    else:
                        attempt = 0
                        while attempt <= retries:
                            attempt += 1
                            try:
                                dfile.unlink()
                                deleted += 1
                                break
                            except Exception as e:
                                print(f"Attempt {attempt}/{retries+1} - Error deleting {dfile}: {e}")
                                if attempt > retries:
                                    print(f"Giving up deleting {dfile}")
                                    errors += 1
                                else:
                                    time.sleep(wait)
            # Directories
            for dname in dirnames:
                dsub = Path(dirpath) / dname
                ssub = s_dir / dname
                if not ssub.exists():
                    if dry_run:
                        print(f"[DRY-RUN] Would remove directory tree: {dsub}")
                        deleted += 1
                    else:
                        attempt = 0
                        while attempt <= retries:
                            attempt += 1
                            try:
                                shutil.rmtree(dsub)
                                deleted += 1
                                break
                            except Exception as e:
                                print(f"Attempt {attempt}/{retries+1} - Error removing directory {dsub}: {e}")
                                if attempt > retries:
                                    print(f"Giving up removing {dsub}")
                                    errors += 1
                                else:
                                    time.sleep(wait)

    print('\nMirror summary:')
    print(f'  Copied/updated: {copied}')
    print(f'  Skipped (up-to-date): {skipped}')
    print(f'  Deleted: {deleted}')
    print(f'  Errors: {errors}')

    return errors == 0


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Mirror a local source folder (drive letter or UNC) to a destination NAS path')
    parser.add_argument('--list-profiles', action='store_true', help='List configured profiles')
    parser.add_argument('--create-profile', nargs='?', const='', help='Create a new profile (optionally provide name)')
    parser.add_argument('--delete-profile', help='Delete the named profile')
    parser.add_argument('--profile', help='Use the named profile')
    parser.add_argument('--use-saved', action='store_true', help='Use default profile if present')
    parser.add_argument('--save', action='store_true', help='Save provided source/destination after prompting (creates/overwrites profile)')
    parser.add_argument('--dry-run', action='store_true', help='Show actions without copying/deleting')
    parser.add_argument('--no-delete', action='store_true', help="Don't delete files in destination that are missing from source")
    parser.add_argument('--source', help='(Optional) Full source path, e.g. G:\\ or G:\\Folder')
    parser.add_argument('--dest', help='(Optional) Destination path on NAS (UNC or local path)')
    # Robocopy-like options
    parser.add_argument('--retries', type=int, default=3, help='Number of retries for transient errors (default: 3)')
    parser.add_argument('--retry-wait', type=int, default=5, help='Seconds to wait between retries (default: 5)')
    parser.add_argument('--checksum', action='store_true', help='Compare files using checksum (md5) instead of size/mtime')
    parser.add_argument('--time-tolerance', type=int, default=1, help='Seconds tolerance when comparing modification times (default: 1)')
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

    # If source not provided, interactively prompt
    if not source:
        print('\nEnter source and destination local paths:')
        source = prompt_input('Source path (e.g. G:\\ or G:\\Shared Drive\\Folder)')
        if not source:
            print('Source path is required. Exiting.')
            sys.exit(1)
    if not dest:
        dest = prompt_input('Destination path on NAS (e.g. \\NAS\\Backups\\gdrive or D:\\Backups\\gdrive)')
        if not dest:
            print('Destination path is required. Exiting.')
            sys.exit(1)

    # Validate local paths
    if not is_local_path(source):
        print(f"Source path is not an absolute path: {source}")
        sys.exit(1)
    if not is_local_path(dest):
        print(f"Destination path is not an absolute path: {dest}")
        sys.exit(1)

    print('\nSummary:')
    print('  Source:', source)
    print('  Destination:', dest)
    proceed = prompt_input('Proceed with mirror? (yes/no)', default='no')
    if proceed.lower() not in ('y', 'yes'):
        print('Aborted by user.')
        sys.exit(0)

    # Save profile if requested
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

    # Run mirror
    print('\nStarting mirror... (this can take a long time depending on data size)')
    success = mirror_directory(
        source,
        dest,
        dry_run=args.dry_run,
        delete_extra=not args.no_delete,
        retries=args.retries,
        wait=args.retry_wait,
        checksum=args.checksum,
        time_tolerance=args.time_tolerance,
    )
    if success:
        print('\nMirror completed successfully.')
        sys.exit(0)
    else:
        print('\nMirror completed with errors. See output above.')
        sys.exit(2)


if __name__ == '__main__':
    main()
