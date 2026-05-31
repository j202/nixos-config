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

Rebuild:

```bash
sudo nixos-rebuild switch --flake .#alex-pc
```

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
