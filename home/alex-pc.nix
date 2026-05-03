# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PC-specific home config — shared base plus Hyprland desktop.
{ config, pkgs, ... }:
{
  imports = [
    ./alex.nix
    ./modules/hyprland.nix
  ];

  catppuccin.kitty.enable = true;
}
