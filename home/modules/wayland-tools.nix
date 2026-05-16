# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Generic Wayland tools — launcher, terminal, notifications.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  flavor = config.catppuccin.flavor;
  base = palette.${flavor}.colors.base.rgb;
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
      display-run = " ";
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
      tab_bar_style = "custom";
      tab_bar_margin_height = "4 4";
      # The Catppuccin theme sets inactive_tab_background to mantle,
      # almost identical to the bar background. Override to surface1
      # so inactive bubbles are clearly visible.
      inactive_tab_background = "${palette.${flavor}.colors.surface1.hex}";
    };
  };

  # Filled bubble tabs. Both active and inactive use the same shape; colors
  # come from draw_data so inactive_tab_background above takes effect.
  # chr() avoids encoding PUA characters as literals in the Nix source.
  xdg.configFile."kitty/tab_bar.py".text = ''
    from kitty.fast_data_types import Screen
    from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

    LEFT_CAP  = chr(0xE0B6)
    RIGHT_CAP = chr(0xE0B4)


    def draw_tab(
        draw_data: DrawData, screen: Screen, tab: TabBarData,
        before: int, max_title_length: int, index: int,
        is_last: bool, extra_data: ExtraData,
    ) -> int:
        tab_bg = as_rgb(draw_data.tab_bg(tab))
        tab_fg = as_rgb(draw_data.tab_fg(tab))
        bar_bg = as_rgb(int(draw_data.default_bg))

        title = tab.title
        if len(title) > max_title_length - 4:
            title = title[: max(max_title_length - 5, 1)] + "…"

        screen.cursor.fg = tab_bg
        screen.cursor.bg = bar_bg
        screen.draw(LEFT_CAP)

        screen.cursor.fg = tab_fg
        screen.cursor.bg = tab_bg
        screen.draw(f" {title} ")

        screen.cursor.fg = tab_bg
        screen.cursor.bg = bar_bg
        screen.draw(RIGHT_CAP)

        screen.cursor.fg = bar_bg
        screen.cursor.bg = bar_bg
        screen.draw(" ")

        return screen.cursor.x
  '';

}
