# nixos-config

Personal NixOS configuration for:

- **alex-pc** — ASRock Z790 / i7-13700K / RX 7900 XT (nixos-unstable)
- **xpsm1330** — Dell XPS M1330 (nixos-25.11 stable)

## Setup

After cloning, install the pre-commit hooks:

```bash
nix develop --command true
```

This installs git hooks that run on every commit:

| Hook | What it does |
| ------ | ------------- |
| **nixfmt** | Formats all `.nix` files |
| **cspell** | Spell-checks all text files |
| **deadnix** | Flags unused let bindings and lambda args |
| **statix** | Flags Nix anti-patterns (e.g. repeated keys) |
| **check-merge-conflict** | Fails if any file contains a merge conflict marker (`<<<<<<<`, `=======`, `>>>>>>>`) |
| **detect-private-key** | Fails if any file contains a private key header (RSA, EC, OpenSSH, etc.) |
| **check-added-large-files** | Fails if any staged file exceeds 500 KB |
| **check-json** | Validates `.json` files are well-formed (excludes `vscode/` which uses JSONC) |
| **mixed-line-ending** | Fails if any file contains CRLF line endings |
| **end-of-file-fixer** | Ensures all files end with a single newline |
| **trim-trailing-whitespace** | Removes trailing whitespace (`.md` files excluded) |
| **shellcheck** | Lints `.sh` files; config in `.shellcheckrc` |
| **shfmt** | Formats `.sh` files (2-space indent, space after redirects) |
| **stylua** | Formats `.lua` files |
| **markdownlint** | Lints `.md` files; config in `.markdownlint.json` |
| **verify-hyprland-config** | Validates the generated Hyprland config with `hyprland --verify-config` |

The hooks are pinned to the versions in `flake.lock` and will be identical on any machine.
Re-run `nix develop --command true` after any `flake.lock` update to pick up new versions.

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#alex-pc
```

## Spell checking

Unknown words go in `.cspell/` — pick the most appropriate dictionary file for the term.
Use `# cspell:ignore word` inline for one-off suppressions.

## Markdown linting

Rules are configured in `.markdownlint.json`. MD013 (line length) is set to 120
characters; table rows are excluded since they can't be wrapped.
