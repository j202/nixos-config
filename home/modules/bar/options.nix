# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Toggle between desktop bar implementations.
# Set myConfig.desktop.shell in alex-pc.nix to switch.
{ lib, ... }:
{
  options.myConfig.desktop.shell = lib.mkOption {
    type = lib.types.enum [
      "waybar"
      "noctalia"
    ];
    default = "waybar";
    description = "Desktop bar/shell — 'waybar' or 'noctalia'.";
  };
}
