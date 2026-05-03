# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PipeWire audio stack with ALSA, PulseAudio compat, and 32-bit support for games.
{ config, lib, pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."10-clock-rate" = {
      "context.properties" = {
        "default.clock.rate" = 192000;
        "default.clock.quantum" = 2048;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 8192;
        "resample.quality" = 15;
      };
    };
  };
}
