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
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
    # catppuccin hyprland uses lua-inline colors not supported until Hyprland >0.55.2
    hyprland.enable = false;
  };
}
