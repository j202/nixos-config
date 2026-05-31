# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ config, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        animation = [
          "fadeIn,  1, 8, linear"
          "fadeOut, 1, 8, linear"
        ];
      };

      background = [
        {
          path = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
          blur_passes = 2;
          blur_size = 5;
          contrast = 0.8;
          brightness = 0.8;
        }
      ];
    };
  };
}
