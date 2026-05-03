# vim: set ft=nix ts=2 sw=2 sts=2 et:
# KDE Plasma 6 — alternative desktop, not active by default.
# To use: replace modules/hyprland.nix with this in the host config.
{ config, lib, pkgs, ... }:
{
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";
  catppuccin.sddm.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "kde";
  };
}
