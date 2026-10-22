#!/usr/bin/env python3
"""Import a Vaultwarden attachment using an isolated, temporary CLI login."""

import getpass
import json
import os
import subprocess
import sys
import tempfile


def main():
    with open(sys.argv[1], encoding='utf-8') as config_file:
        config = json.load(config_file)
    server = config['bw_server']
    item_name = config['bw_gpg_item']
    attachment = config['bw_gpg_attachment']
    key_id = config['pass_gpg_id']
    existing = subprocess.run(
        ['gpg', '--batch', '--with-colons', '--list-secret-keys', key_id],
        capture_output=True,
    )
    if existing.returncode == 0 and b'sec:' in existing.stdout:
        return
    if existing.returncode not in (0, 2):
        raise RuntimeError('Could not inspect the GPG secret keyring')
    with tempfile.TemporaryDirectory(prefix='bw-import-') as directory:
        env = os.environ.copy()
        env.pop('BW_SESSION', None)
        env['BITWARDENCLI_APPDATA_DIR'] = directory

        def bw(*args):
            return subprocess.run(
                ['bw', *args, '--nointeraction'], env=env, stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
            ).stdout

        bw('config', 'server', server)
        email = config['bw_user']
        env['BW_IMPORT_PASSWORD'] = getpass.getpass('Vaultwarden master password: ')
        code = getpass.getpass('Vaultwarden two-factor code (leave blank if disabled): ').strip()
        method = str(config.get('bw_2fa_method', '0'))
        try:
            two_factor = ['--method', method, '--code', code] if code else []
            env['BW_SESSION'] = bw(
                'login', email, '--passwordenv', 'BW_IMPORT_PASSWORD', '--raw', *two_factor
            ).decode().strip()
            env.pop('BW_IMPORT_PASSWORD', None)
            bw('sync')
            items = json.loads(bw('list', 'items', '--search', item_name))
            matches = [item for item in items if item['name'] == item_name]
            if len(matches) != 1:
                raise RuntimeError('Expected exactly one matching Vaultwarden item')
            key = bw('get', 'attachment', attachment, '--itemid', matches[0]['id'], '--raw')
            subprocess.run(
                ['gpg', '--batch', '--import'], input=key,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
            )
            result = subprocess.run(
                ['gpg', '--batch', '--with-colons', '--list-secret-keys', key_id],
                capture_output=True, check=True,
            )
            if b'sec:' not in result.stdout:
                raise RuntimeError('Attachment did not provide the expected private key')
        finally:
            env.pop('BW_IMPORT_PASSWORD', None)
            if env.get('BW_SESSION'):
                try:
                    bw('logout')
                except (OSError, subprocess.CalledProcessError):
                    print('Vaultwarden logout failed; temporary CLI data will be removed.', file=sys.stderr)


if __name__ == '__main__':
    # Never print captured output, key material, environment, or a traceback.
    try:
        main()
    except subprocess.CalledProcessError as exc:
        print(f'Key import failed at {exc.cmd[0]} {exc.cmd[1]} (exit {exc.returncode}). Check connectivity, credentials and two-factor settings if login failed.', file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print('Key import requires bw and gpg on PATH.', file=sys.stderr)
        sys.exit(1)
    except OSError:
        print('Key import could not access temporary CLI data or execute a required command.', file=sys.stderr)
        sys.exit(1)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
    except Exception:
        print('Key import failed while processing the Vaultwarden response.', file=sys.stderr)
        sys.exit(1)
