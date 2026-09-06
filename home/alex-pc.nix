# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PC-specific home config — shared base plus desktop tools.
{ lib, pkgs, ... }:
let
  # gpg-agent's pinentry is used both from this machine's own Hyprland
  # session and from ssh sessions into it — a GUI pinentry can't render
  # without a display, so fall back to curses when there isn't one.
  pinentry-auto = pkgs.writeShellScriptBin "pinentry" ''
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
      exec ${pkgs.pinentry-qt}/bin/pinentry "$@"
    else
      exec ${pkgs.pinentry-curses}/bin/pinentry "$@"
    fi
  '';
in
{
  imports = [
    ./alex.nix
    ./modules/git-personal-identity.nix
    ./modules/git-github-ssh.nix
    ./modules/vkbasalt.nix
    ./modules/wayland-tools.nix
    ./modules/game-save-backup.nix
    ./modules/hyprland
    ./modules/bar/options.nix
    ./modules/bar/waybar.nix
    ./modules/bar/noctalia.nix
  ];

  # Desktop bar: "noctalia" (full shell, notifications, popups)
  #              "waybar"   (minimal bar + mako notifications)
  myConfig.desktop.shell = "noctalia";

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  services.gpg-agent.pinentry.package = lib.mkForce pinentry-auto;
}
