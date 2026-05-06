# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Bluetooth hardware and management applet.
{ config, lib, pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.Policy.AutoEnable = true;
  hardware.bluetooth.settings.Policy.ClassicBondedOnly = false;
  services.blueman.enable = true;
}
