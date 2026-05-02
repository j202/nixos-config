# vim: set ft=nix ts=2 sw=2 sts=2 et:
# XFCE desktop with LightDM and PulseAudio.
# Video driver is host-specific — set services.xserver.videoDrivers in the host config.
{ config, lib, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  services.pipewire.pulse.enable = false;
}
