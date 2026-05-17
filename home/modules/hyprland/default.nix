# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ ... }:
{
  imports = [
    ./apps.nix
    ./lock.nix
    ./monitors.nix
    ./session.nix
    ./theme.nix
    ./wallpaper.nix
    ./wm.nix
  ];
}
