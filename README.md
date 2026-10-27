# WNIX laptop installs

The hardware file describes the installed disks and hardware. The rest of this
repo describes the environment. A generated `hardware-configuration.nix` is an
ordinary NixOS module: replacing the matching file in `hw/` is the intended
reinstall workflow. Keep the generated filesystem types, Btrfs subvolumes,
mount options and LUKS declarations together. There are no disk UUIDs or mount
definitions hidden in `flake.nix` or either software configuration.

| Machine | Replace this file | Small system | Full system |
| --- | --- | --- | --- |
| turing | `hw/system76.nix` | `make turing-stage-one` | `make turing` |
| kleene | `hw/lenovo.nix` | `make kleene-stage-one` | `make kleene` |

`make turing-simple` and `make kleene-simple` are aliases for stage one.
`make` selects the running hostname's **full** configuration. Explicit machine
targets select that machine even if the live USB still calls itself `nixos`.
Run switch targets on the intended installed laptop; use `nixos-install` from
the live USB as shown below. `make check` evaluates all four laptop systems
without installing them. `make turing ACTION=build` builds without switching.

`configuration-stage-one.nix` owns the shared setup and 40 explicit essentials:
Git/GitHub CLI, Chrome, make/compiler, Vim, terminal, tmux/ranger, shell tools,
SSH/GPG, disk tools, plain Python, Home Manager and Codex. Cinnamon, networking,
audio, Bluetooth and the normal user accounts are enabled there too. Home
Manager applies `home/jason.nix`, clones the public `nix`, `exec` and `personal`
repositories under `~/src`, and installs the normal Bash configuration, PATH,
symlinks and themes. First activation needs working internet for those clones;
it waits for network-online and never asks for private GitHub credentials.
Cinnamon's applet customization runs at login once its files exist.

The full `configuration.nix` imports that same module and adds the existing
large Python environments, TeX, book fonts, applications and extra services.
Stage one excludes those additions and Luna's media packages. Cinnamon,
Chrome, the icon theme, compiler and Codex still require downloads; this is a
usable desktop bootstrap, not a tiny rescue image. Speed depends on connection
and binary-cache availability. Keep `flake.lock` during a reinstall so this
also doesn't become an upgrade.

## Apply this repo to the installation already running on turing

This repo already contains today's generated turing hardware file, unchanged.
The old ext4/label layout has been replaced by the new encrypted Btrfs layout.
No partitioning, formatting or relabeling is part of these commands.

From your checkout, as Jason:

```sh
# Save the installer's configuration before replacing the directory.
sudo mv /etc/nixos /etc/nixos.before-wnix
sudo ln -s /home/jason/src/nix /etc/nixos
make turing-stage-one
```

Use the actual checkout path for the symlink if it differs. If `/etc/nixos` is
already that symlink, leave it alone. Choose a different backup name if one
already exists. Existing account passwords are preserved. For a newly created
Jason account, run `sudo passwd jason` before relying on graphical login.

After logging into the familiar desktop:

```sh
gh auth login
gh auth setup-git
make turing
```

The full build enables private dotfiles and clones `secret` and `legacy`.
Authenticate **as Jason**, not via `sudo gh`. Those repositories and their
credentials are not needed for stage one. To download/build the large system
while continuing to use stage one, run `make turing ACTION=build`, then
`make turing` later to activate it. Changing stages doesn't reformat disks.
A later stage-one switch will remove full-only apps from the active profile.

Every turing build currently ends with a cowsay reminder and the exact
`lord --verbose` heredoc. Once agent access works **on turing**, run:

```sh
./TODO-TELL-AN-AGENT-TO-SWITCH-THE-UUIDS-TO-THE-LABELS-IN-dev-disk-by-label
```

The executable includes the original hardware snapshot, instructions to verify
outer LUKS labels separately from inner filesystem labels, and instructions to
remove itself and the reminder when finished. Its `--remind` mode only prints
instructions; it does not launch an agent. The generated encrypted swap mapper
has no corresponding LUKS unlock declaration; the follow-up must check the
actual machine's unlock mechanism. It is preserved here exactly as supplied.

## A future reinstall from the live USB

Partition, unlock, format and mount the machine as desired **before** using
this repo. Mount the complete destination layout under `/mnt`, including EFI,
`/home`, `/nix`, any Btrfs subvolumes and nested mounts. Enable the intended
swap before generating the hardware file. Generation records the mounted
layout; it does not design or recreate it. See the [NixOS installation
manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual) for
mounting and `nixos-install` details.

Open a root shell on the live USB and get the two tools needed before the
bootstrap system exists:

```sh
sudo -i
nix-shell -p git gnumake
```

For turing (substitute `kleene` and `hw/lenovo.nix` for that laptop):

```sh
# Check the mounted destination before generating its hardware module.
findmnt -R /mnt
lsblk -f
swapon --show

mkdir -p /mnt/home/jason/src
git clone https://github.com/notarealdeveloper/nix /mnt/home/jason/src/nix
cd /mnt/home/jason/src/nix

# Prints the hardware module without overwriting this repo's software config.
nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-configuration.nix
cp /tmp/hardware-configuration.nix hw/system76.nix

nixos-install --root /mnt --flake "path:$PWD#turing-stage-one"

# nixos-install asks for root's password; Jason needs his own password as well.
nixos-enter --root /mnt -c 'passwd jason'
nixos-enter --root /mnt -c 'chown jason:users /home/jason /home/jason/src'
nixos-enter --root /mnt -c 'chown -R jason:users /home/jason/src/nix'
```

If you already generated a correct hardware file, copy that one instead of
regenerating it. Review the LUKS unlock declarations and swap entry against the
fresh installer configuration, especially any hand-written key/unlock settings.
Don't blindly copy the installer's `configuration.nix` over this repo's file.

After installation, save `/mnt/etc/nixos` if it exists, then make
`/mnt/etc/nixos` a symlink to `/home/jason/src/nix`. The target is the path
**after boot**, so it must not start with `/mnt`. For example, when the installer
left a normal directory and the backup name is unused:

```sh
mv /mnt/etc/nixos /mnt/etc/nixos.before-wnix
ln -s /home/jason/src/nix /mnt/etc/nixos
reboot
```

Log in as Jason, authenticate GitHub, then run `make turing` (or `make kleene`).
No chroot is needed to install packages. `nixos-enter` above just sets the
password and checkout ownership. Home Manager's first activation happens when
the installed system boots. If the network was unavailable then, connect it
and run `sudo systemctl restart home-manager-jason`; inspect failures with
`journalctl -u home-manager-jason -b`. Existing dotfiles are backed up with the
`.backup` suffix; if that name already exists, move it aside before retrying.
See [Home Manager's NixOS module](https://nix-community.github.io/home-manager/installation/nixos.html)
for how the home environment is activated with the system.

## What a hardware replacement can and cannot cover

For these two x86-64 UEFI laptops using systemd-boot, copying the newly generated
hardware module is normally the only machine-specific configuration change.
Bootloader choice and the latest-kernel policy live in `os/linux-nixos.nix`.
If a future install changes firmware mode, bootloader, CPU architecture,
manual LUKS key handling, or needs special hardware drivers, check those too.
A generated file alone cannot express choices it didn't detect. Keep the
existing `system.stateVersion`/`home.stateVersion` unless deliberately migrating
their defaults; don't bump them just because you're reinstalling or upgrading.

Keep a checkout on a filesystem available during boot and system activation.
Configuration does not restore documents, private credentials or uncommitted
work, and it does not partition disks. Build/evaluation checks cannot prove an
unlock password or an on-disk UUID; verify those on the target before rebooting.

For a new laptop, put its generated module in `hw/<name>.nix` and add its
hostname/path to `laptops` in `flake.nix`. Both flake configurations are derived
from that one mapping. Add the hostname to `LAPTOPS` in `Makefile` to expose the
full, stage-one and simple targets. These shared laptop profiles assume an
x86-64 machine; a different architecture needs a matching package set too.

The Makefile uses `path:` flake references so new local files are included
even before `git add`. Direct `--flake .#...` in a Git checkout excludes
untracked files: add new modules to Git or use `--flake "path:$PWD#..."` as in
the install commands. Commit the new hardware file when the installation is
verified so the next clone has the correct configuration.
