# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PC-specific home config — shared base plus desktop tools.
{ ... }:
{
  imports = [
    ./alex.nix
    ./modules/qutebrowser.nix
    ./modules/vkbasalt.nix
    ./modules/wayland-tools.nix
    ./modules/hyprland
    ./modules/bar/options.nix
    ./modules/bar/waybar.nix
    ./modules/bar/noctalia.nix
  ];

  # Desktop bar: "noctalia" (full shell, notifications, popups)
  #              "waybar"   (minimal bar + mako notifications)
  myConfig.desktop.shell = "noctalia";

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
    bat.enable = true;
    fish.enable = true;
    starship.enable = true;
    btop.enable = true;
    fzf.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };
}
