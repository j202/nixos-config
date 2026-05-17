# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ config, lib, ... }:
{
  # Hyprpaper only used with waybar shell; noctalia manages its own wallpaper.
  services.hyprpaper = lib.mkIf (config.myConfig.desktop.shell == "waybar") {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "DP-1";
          path = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
          fit_mode = "cover";
        }
        {
          monitor = "DP-4";
          path = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
          fit_mode = "cover";
        }
        {
          monitor = "";
          path = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };
}
