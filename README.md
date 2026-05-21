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
|------|-------------|
| **nixfmt** | Formats all `.nix` files |
| **cspell** | Spell-checks all text files |
| **deadnix** | Flags unused let bindings and lambda args |
| **statix** | Flags Nix anti-patterns (e.g. repeated keys) |
| **end-of-file-fixer** | Ensures all files end with a single newline |
| **trim-trailing-whitespace** | Removes trailing whitespace (`.md` files excluded) |
| **verify-hyprland-config** | Validates the generated Hyprland config with `hyprland --verify-config` |

The hooks are pinned to the versions in `flake.lock` and will be identical on any machine. Re-run `nix develop --command true` after any `flake.lock` update to pick up new versions.

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#alex-pc
```

## Spell checking

Unknown words go in `.cspell/` — pick the most appropriate dictionary file for the term. Use `# cspell:ignore word` inline for one-off suppressions.
