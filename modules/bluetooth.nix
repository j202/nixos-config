# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Bluetooth hardware and management applet.
{ config, lib, pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
