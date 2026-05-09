# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Generic Wayland tools — launcher, terminal, notifications.
{ config, lib, pkgs, ... }:

let
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  flavor = config.catppuccin.flavor;
  base   = palette.${flavor}.colors.base.rgb;
  bgRgba = "rgba(${toString base.r}, ${toString base.g}, ${toString base.b}, 0.82)";
in
{
  catppuccin.rofi.enable = true;
  catppuccin.kitty.enable = true;

  home.packages = with pkgs; [
    xdg-utils
  ];

  # ── Rofi ──────────────────────────────────────────────────────────────────

  # Thin wrapper: @theme/@import are catppuccin-managed; we add transparency
  # (rgba computed from the active flavor's palette) and icon size only.
  # mkForce needed because catppuccin.rofi sets programs.rofi.theme directly.
  home.file.".local/share/rofi/themes/rofi-ext.rasi".text = ''
    @theme "catppuccin-default"
    @import "catppuccin-${flavor}"

    window {
      background-color: ${bgRgba};
      width:            800px;
      border-radius:    12px;
    }

    listview {
      lines:        8;
      border:       1px solid 0px 0px;
      border-color: @surface1;
    }

    element normal.normal {
      background-color: transparent;
    }

    element alternate.normal {
      background-color: transparent;
    }

    textbox-prompt-colon {
      str: "";
    }

    element-icon {
      size: 48px;
    }
  '';

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = lib.mkForce "rofi-ext";
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = " ";
      display-run  = " ";
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
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
      cursor_trail = 3;
      cursor_trail_decay = "0.05 0.4";
      cursor_trail_start_threshold = 2;
    };
  };

}
