# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Gaming stack — Steam, performance tools, controller support.
{ config, lib, pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.corectrl.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  hardware.xpadneo.enable = true;

  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  environment.systemPackages = with pkgs; [
    mangohud
    wineWow64Packages.waylandFull
  ];
}
