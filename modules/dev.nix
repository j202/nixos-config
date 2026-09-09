# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Development toolchain — languages, LSPs, and build tools.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      ansible
      cargo
      clippy
      cspell
      gcc
      gh
      gnumake
      go
      golint
      gopls
      gotools
      lazygit
      lua-language-server
      luarocks
      meld
      nil
      nixfmt
      nodejs
      pkg-config
      pre-commit
      pyright
      python3
      python3Packages.numpy
      python3Packages.pip
      python3Packages.requests
      python3Packages.virtualenv
      ruff
      rust-analyzer
      rustc
      rustfmt
      shellcheck
      shfmt
      statix
      tree-sitter
      ty
      uv
    ]
    # claude-code's Bun runtime requires AVX, which this host's Core 2 Duo predates
    ++ lib.optional (config.networking.hostName != "xpsm1330") claude-code;
}
