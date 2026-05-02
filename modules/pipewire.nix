# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PipeWire audio stack with ALSA, PulseAudio compat, and 32-bit support for games.
{ config, lib, pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
