# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Generic Wayland tools — launcher, terminal, notifications.
{ config, pkgs, ... }:
{
  catppuccin.rofi.enable = true;
  catppuccin.kitty.enable = true;

  home.packages = with pkgs; [
    wlogout
    xdg-utils
  ];

  # ── Rofi ──────────────────────────────────────────────────────────────────

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
    };
  };

  # ── Kitty ─────────────────────────────────────────────────────────────────

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

}
