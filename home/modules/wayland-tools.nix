# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Generic Wayland tools — launcher, terminal, notifications.
{ config, lib, pkgs, ... }:

let
  # Read the base color for the active catppuccin flavor from the palette package
  # so the rgba background tracks flavor changes without any hardcoded hex values.
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  flavor = config.catppuccin.flavor;
  base        = palette.${flavor}.colors.base.rgb;
  opacity     = "0.82";
  bgRgba      = "rgba(${toString base.r}, ${toString base.g}, ${toString base.b}, ${opacity})";
in
{
  catppuccin.rofi.enable = true;
  catppuccin.kitty.enable = true;

  home.packages = with pkgs; [
    wlogout
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
