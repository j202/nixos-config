# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Dell XPS M1330 — old hardware, resource-constrained
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;
  # Limit RAM to 2 GB — hardware cap on this machine
  boot.kernelParams = [ "mem=2G" ];

  networking.hostName = "xpsm1330";

  services.xserver = {
    enable = true;
    videoDrivers = [ "nouveau" ];
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  # PulseAudio — PipeWire too heavy for this hardware
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  services.pipewire.pulse.enable = false;

  # Limit parallel builds — only 2 GB RAM
  nix.settings.max-jobs = 1;

  system.stateVersion = "25.11";
}
