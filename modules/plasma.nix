# vim: set ft=nix ts=2 sw=2 sts=2 et:
# KDE Plasma 6 — alternative desktop, not active by default.
# To use: replace modules/hyprland.nix with this in the host config.
{
  pkgs,
  ...
}:
{
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";
  catppuccin.sddm.enable = true;
  catppuccin.sddm.background = "${pkgs.fetchurl {
    url = "https://assets.alex-sh.co.uk/wallpaper/night-sky-space-colorful-scenery-4k-wallpaper-uhdpaper.com.jpg";
    hash = "sha256-B8GwZ/n0pty4zvsWiEeXy8SMrlWU5gzBAP4MROmWfq4=";
  }}";

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
