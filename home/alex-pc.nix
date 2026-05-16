# vim: set ft=nix ts=2 sw=2 sts=2 et:
# PC-specific home config — shared base plus desktop tools.
{ ... }:
{
  imports = [
    ./alex.nix
    ./modules/qutebrowser.nix
    ./modules/vkbasalt.nix
    ./modules/wayland-tools.nix
    ./modules/hyprland.nix
    ./modules/bar/options.nix
    ./modules/bar/waybar.nix
    ./modules/bar/noctalia.nix
  ];

  # Desktop bar: "noctalia" (full shell, notifications, popups)
  #              "waybar"   (minimal bar + mako notifications)
  myConfig.desktop.shell = "noctalia";

  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  catppuccin.bat.enable = true;
  catppuccin.fish.enable = true;
  catppuccin.starship.enable = true;
  catppuccin.btop.enable = true;
  catppuccin.fzf.enable = true;
  catppuccin.tmux.enable = true;
  catppuccin.yazi.enable = true;
  catppuccin.zellij.enable = true;
}
