# nixos-config

Personal NixOS configuration for:

- **alex-pc** — ASRock Z790 / i7-13700K / RX 7900 XT (nixos-unstable)
- **xpsm1330** — Dell XPS M1330 (nixos-25.11 stable)

## Setup

After cloning, install the pre-commit hooks:

```bash
nix develop
exit
```

This installs git hooks that run **nixfmt** (formatter) and **cspell** (spell checker) on every commit. The hooks are pinned to the versions in `flake.lock` and will be identical on any machine.

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#alex-pc
```

## Spell checking

Unknown words go in `.cspell/` — pick the most appropriate dictionary file for the term. Use `# cspell:ignore word` inline for one-off suppressions.
