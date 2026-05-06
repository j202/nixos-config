# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PC-specific home config — shared base plus desktop tools.
{ config, pkgs, ... }:
{
  imports = [
    ./alex.nix
    ./modules/wayland-tools.nix
    ./modules/hyprland.nix
  ];

  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  catppuccin.bat.enable = true;
  catppuccin.fish.enable = true;
  catppuccin.starship.enable = true;
  catppuccin.btop.enable = true;
  catppuccin.fzf.enable = true;
  catppuccin.tmux.enable = true;
  catppuccin.yazi.enable = true;
  catppuccin.zellij.enable = true;
}
