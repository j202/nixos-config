# vim: set ft=nix ts=2 sw=2 sts=2 et:
# System-level Hyprland setup — display manager, session, Wayland environment.
{ config, lib, pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };

  security.pam.services.hyprlock = { };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];
}
