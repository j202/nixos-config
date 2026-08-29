# nixos-config

Personal system configuration covering NixOS machines and standalone home-manager.

## Machines

| Config | Host | Notes |
| ------ | ---- | ----- |
| `alex-pc` | ASRock Z790 / i7-13700K / RX 7900 XT | nixos-unstable |
| `xpsm1330` | Dell XPS M1330 | nixos-25.11 stable |
| `alex-standalone` | Any non-NixOS Linux | Standalone home-manager |

## NixOS setup

After cloning, install the pre-commit hooks:

```bash
nix develop --command true
```

An `.envrc` (`use flake`) is also checked in, so with `direnv` (already set up via
`programs.direnv` in `home/alex.nix`) and `direnv allow` run once, the flake's dev
shell — `agenix`, pre-commit, etc. — loads automatically into your normal shell on
`cd`, without dropping into a nested `nix develop` subshell.

Rebuild:

```bash
sudo nixos-rebuild switch --flake .#alex-pc
```

## Secrets (agenix)

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) and committed
to this repo as `.age` files under `secrets/` — safe to keep public, since only the
holder of a matching age private key can decrypt them. `secrets/secrets.nix` lists
which public key(s) ("recipients") each secret is encrypted for.

Decryption happens automatically on `nixos-rebuild switch`, using the private key at
`/etc/age/key` (`age.identityPaths` in `modules/base.nix`). That key isn't managed by
this repo — it's a personal age key kept in the password manager, restored to
`/etc/age/key` by hand on a fresh machine.

Currently encrypted:

- `netrc.age` → used as `nix.settings.netrc-file` (build system credentials).
- `ssh_config.age` → deployed to `~/.ssh/config` (`age.secrets.ssh-config` in
  `modules/base.nix`).

**The encrypted `.age` file is canonical, not the decrypted file on disk** — e.g.
`~/.ssh/config` is just a deployment target. Editing it directly works until the next
`nixos-rebuild switch`, which overwrites it back to whatever's committed. To make a
change stick, edit the secret itself and re-deploy:

```bash
cd secrets
sudo -E agenix -e ssh_config.age -i /etc/age/key   # opens $EDITOR, re-encrypts on save
cd ..
sudo nixos-rebuild switch --flake .#alex-pc
```

Run from inside `secrets/`, using the bare filename — agenix looks for `./secrets.nix`
relative to the current directory (not `secrets/secrets.nix`) and uses whatever you
pass as the exact lookup key. `sudo` is required to read `/etc/age/key`
(root-owned, `0400`); `-E` preserves `$EDITOR` through it.

`agenix` itself is on `PATH` both system-wide (`environment.systemPackages` in
`flake.nix`, for editing on the machine that actually needs the decrypted secret) and
in `nix develop` (for editing from a checkout that isn't necessarily deployed, e.g.
before a fresh machine's first switch).

To add a new secret: encrypt a file with `age -r <public-key> -o
secrets/<name>.age <path-to-plaintext>`, add `"<name>.age".publicKeys = [ alex ];` to
`secrets/secrets.nix`, then reference it via `age.secrets.<name>` in the relevant
module (`file`, and optionally `path`/`owner`/`mode` if it needs to land somewhere
specific, as `ssh-config` does).

To add a second machine as a recipient (e.g. `xpsm1330`): generate/obtain its age
public key, add it alongside `alex` in `secrets/secrets.nix`, then re-run the `age
-r` encrypt command for each secret with both public keys passed (one `-r` per
recipient) so either machine's private key can decrypt it.

## Game save backups (alex-pc)

Ludusavi collects game saves and syncs them to Google Drive via rclone, triggered
after a game session ends rather than on a timer (see `home/modules/game-save-backup.nix`
and `ludusavi/config.yaml`). The Google Drive connection is authenticated per-machine
and isn't something Nix can set up for you, so after a fresh install of `alex-pc`:

```bash
ludusavi cloud set google-drive
```

This opens a browser for one-time OAuth consent. Only a non-secret remote ID gets
written back into `ludusavi/config.yaml` (verified against Ludusavi's own config
schema) — the actual credential lives in rclone's own state, not in this repo.

**Known gotcha**: this can fail with `bind: address already in use` on port `53682`
(rclone's local OAuth callback listener) if a previous attempt was left running in
the background without completing. Fix:

```bash
ss --tcp --listening --numeric --processes | grep 53682   # find the stray rclone process
kill <pid>              # then retry `ludusavi cloud set google-drive`
```

Also needed once per game, since Steam/Lutris have no way to apply this globally:

- Steam: prepend `~/.local/bin/game-backup-steam-wrapper.sh` to each game's launch
  options (e.g. `~/.local/bin/game-backup-steam-wrapper.sh %command%`).
- Lutris: set the game's "Post-exit script" to `~/.local/bin/game-backup-trigger.sh`.

## Standalone home-manager (non-NixOS)

### Prerequisites

Install Nix (multi-user):

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Clone the repo:

```bash
git clone https://github.com/j202/nixos-config ~/nixos-config
```

### Bootstrap

Install the standalone mise binary — this is separate from the Nix-managed mise
and is what makes tools accessible inside containers that mount `$HOME`:

```bash
curl https://mise.run | sh
```

This installs mise to `~/.local/bin/mise`. Both installations share
`~/.config/mise/config.toml` (written by home-manager on activation).

Create a git identity file (keeps your identity out of this repo):

```bash
mkdir -p ~/.gitconfig.d
cat > ~/.gitconfig.d/identity << 'EOF'
[user]
    name = Your Name
    email = you@example.com
EOF
```

### Apply

On the first run, home-manager is not installed yet so use `nix run`:

```bash
nix run home-manager -- switch --flake ~/nixos-config#alex-standalone --impure
```

After that, home-manager is available directly:

```bash
home-manager switch --flake ~/nixos-config#alex-standalone --impure
```

The `--impure` flag is required — it allows the config to read `$USER` and `$HOME`
from the environment rather than having them hardcoded in the repo.

### Updating

Pull the latest config and re-apply:

```bash
git -C ~/nixos-config pull
home-manager switch --flake ~/nixos-config#alex-standalone --impure
```

## mise

CLI tools in `home/alex-standalone.nix` under `programs.mise.settings.tools` are
installed by mise into `~/.local/share/mise/installs/`. This is inside `$HOME`, so
they are accessible in containers that mount `$HOME`, unlike Nix-managed packages
which live in `/nix/store`.

Shims in `~/.local/share/mise/shims/` delegate to the real binaries. The shims call
back into `~/.local/bin/mise` (the curl-installed binary), so both installations
need to be present for container use.

### Adding a tool

Add it to `programs.mise.settings.tools` in `home/alex-standalone.nix`:

```nix
programs.mise.globalConfig.settings.tools = {
  ripgrep = "latest";
  my-new-tool = "latest";  # add here
};
```

Then re-apply:

```bash
home-manager switch --flake ~/nixos-config#alex-standalone --impure
```

mise installs the tool on activation.

### Pinning a version

Use a specific version instead of `"latest"`:

```nix
programs.mise.globalConfig.settings.tools = {
  ripgrep = "14.1.1";
};
```

### Useful mise commands

```bash
mise ls                    # show installed tools and active versions
mise ls-remote ripgrep     # list available versions of a tool
mise upgrade               # upgrade all tools to latest
mise which rg              # show path to the active ripgrep binary
```

## Pre-commit hooks

Install with `nix develop --command true`. Re-run after any `flake.lock` update.

| Hook | What it does |
| ---- | ------------ |
| **nixfmt** | Formats all `.nix` files |
| **cspell** | Spell-checks all text files |
| **deadnix** | Flags unused let bindings and lambda args |
| **statix** | Flags Nix anti-patterns (e.g. repeated keys) |
| **check-merge-conflict** | Fails if any file contains a merge conflict marker |
| **detect-private-key** | Fails if any file contains a private key header |
| **check-added-large-files** | Fails if any staged file exceeds 500 KB |
| **check-json** | Validates `.json` files (excludes `vscode/` which uses JSONC) |
| **mixed-line-ending** | Fails if any file contains CRLF line endings |
| **end-of-file-fixer** | Ensures all files end with a single newline |
| **trim-trailing-whitespace** | Removes trailing whitespace (`.md` files excluded) |
| **shellcheck** | Lints `.sh` files |
| **shfmt** | Formats `.sh` files (2-space indent, space after redirects) |
| **stylua** | Formats `.lua` files |
| **markdownlint** | Lints `.md` files; config in `.markdownlint.json` |
| **verify-hyprland-config** | Validates the generated Hyprland config |

## Spell checking

Unknown words go in `.cspell/` — pick the most appropriate dictionary file.
Use `# cspell:ignore word` inline for one-off suppressions.

## Markdown linting

Rules in `.markdownlint.json`. MD013 (line length) is set to 120 characters;
table rows are excluded.
