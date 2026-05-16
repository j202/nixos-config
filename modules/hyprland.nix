# vim: set ft=nix ts=2 sw=2 sts=2 et:
# System-level Hyprland setup — display manager, session, Wayland environment.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;

  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  catppuccin.sddm = {
    enable = true;
    background = "${pkgs.fetchurl {
      url = "https://assets.alex-sh.co.uk/wallpaper/night-sky-space-colorful-scenery-4k-wallpaper-uhdpaper.com.jpg";
      hash = "sha256-B8GwZ/n0pty4zvsWiEeXy8SMrlWU5gzBAP4MROmWfq4=";
    }}";
  };

  security.pam.services.hyprlock = { };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];
}
