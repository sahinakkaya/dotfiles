# Joplin encrypted profiles

Run the complete workstation playbook on a fresh Fedora installation:

```sh
ansible-playbook ansible/setup.yml --ask-become-pass
```

The password store must contain `joplin` (override `joplin_password_entry`
if needed), with the encryption password on the first line. GPG must be able
to decrypt it. The complete playbook installs dependencies, the NVM CLI,
and runs `yolk sync` before configuring Joplin. Yolk manages the scripts,
the desktop entry, and the `~/.local/bin/joplin` symlink from `eggs/home`.
Run `yolk sync` to deploy subsequent dotfile changes.
The desktop entry resolves `joplin-secure` through the desktop session PATH,
which must include `~/.local/bin`.

To rerun only Joplin setup after those prerequisites are installed:

```sh
ansible-playbook ansible/setup.yml --tags joplin
```

Close Joplin Desktop and CLI first. Setup refuses to continue when it detects
Joplin running. Missing profiles are created as empty directories; existing
profiles are copied into the mounted encrypted filesystem, compared using
`diff -qr`, and renamed to `.backup` before creating configuration symlinks.
Conflicting encrypted profiles, unrelated symlinks, and existing backup paths
stop migration without overwriting them. Backups are never deleted by Ansible.
They remain plaintext until you choose to remove them after verifying your notes.

An existing `gocryptfs.conf` skips initialization. To restore encrypted notes,
restore the entire `joplin-encrypted` directory before running setup and use
its original password. Setup unmounts storage that it mounted itself, including
on migration failure; an existing mount is preserved.

The desktop entry runs `joplin-secure`; `~/.local/bin/joplin` runs
`joplin-cli-secure`. Zsh already places this directory before NVM on PATH.
The CLI launcher discovers the default NVM Node version rather than hardcoding
it. Use `joplin-lock` to unmount manually. No systemd units are managed.
