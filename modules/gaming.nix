# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Gaming stack — Steam, performance tools, controller support.
{ config, lib, pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;
  programs.mangohud.enable = true;
  programs.gamescope.enable = true;

  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };

  hardware.xpadneo.enable = true;

  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  programs.lutris.enable = true;

  environment.systemPackages = with pkgs; [
    ludusavi
    wineWowPackages.waylandFull
    winetricks
  ];
}
