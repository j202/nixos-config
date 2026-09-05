# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  restart-noctalia = pkgs.writeShellScriptBin "restart-noctalia" ''
    pkill noctalia || true
    while pgrep noctalia > /dev/null; do sleep 0.1; done
    exec noctalia
  '';
in
{
  config = lib.mkIf (config.myConfig.desktop.shell == "noctalia") {

    home.packages = [ restart-noctalia ];

    # noctalia auto-discovers a terminal via $TERMINAL, falling back to a list of
    # common emulators (including kitty) if unset — set it explicitly for certainty.
    home.sessionVariables.TERMINAL = "kitty";

    programs.noctalia = {
      enable = true;

      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        shell = {
          font_family = "DejaVu Sans";
          time_format = "{:%H:%M} ";
          telemetry_enabled = false;
          avatar_path = "${config.home.homeDirectory}/.face";
          # Broad translucency, matching the old ui.translucentWidgets intent.
          settings_window_translucent = true;

          panel = {
            transparency_mode = "soft";
            # Old panelsAttachedToBar = false meant every panel floated, detached
            # from the bar. Wallpaper/session still follow that; Control Center
            # was moved back to attached (its v5 default) via the settings GUI.
            wallpaper_placement = "floating";
            session_placement = "floating";
            open_near_click_control_center = true;
            open_near_click_session = true;
          };

          screen_corners.enabled = true;

          session = {
            grid = true;
            # v5 moved the countdown from one global duration to per-action
            # countdown_seconds, which means redeclaring the whole default
            # action list rather than overriding one field of it. Declaring the
            # array at all also drops v5's built-in "1"-"5" shortcut defaults
            # (only assigned when actions is left unset entirely), so they're
            # set explicitly here too.
            actions = [
              {
                action = "lock";
                shortcut = "l";
              }
              {
                action = "logout";
                countdown_seconds = 5;
                shortcut = "o";
              }
              {
                action = "lock_and_suspend";
                countdown_seconds = 5;
                shortcut = "s";
              }
              {
                action = "reboot";
                countdown_seconds = 5;
                shortcut = "r";
              }
              {
                action = "shutdown";
                countdown_seconds = 5;
                variant = "destructive";
                shortcut = "u";
              }
            ];
          };
        };

        wallpaper = {
          enabled = true;
          directory = "${config.home.homeDirectory}/Pictures/wallpapers";
          fill_mode = "crop";
        };

        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 660;
            action = "lock";
          };
          "screen-off" = {
            enabled = true;
            timeout = 600;
            action = "screen_off";
          };
        };

        keybinds = {
          up = [
            "up"
            "ctrl+p"
          ];
          down = [
            "down"
            "ctrl+n"
          ];
          left = [
            "left"
            "ctrl+h"
          ];
          right = [
            "right"
            "ctrl+l"
          ];
          cancel = [
            "escape"
            "ctrl+["
          ];
        };

        osd.background_opacity = 0.85;

        lockscreen = {
          enabled = true;
          blur_intensity = 0.8;
          monitors = [ ];
        };

        location.auto_locate = true;

        weather.enabled = true;

        control_center = {
          sidebar = "full";
          sidebar_section = "compact";
          width = 800;
        };

        bar.default = {
          position = "top";
          background_opacity = 0.0;
          capsule = true;
          capsule_opacity = 1.0;
          # Tried the old bar.showOutline as border_width = 1.0; turned back off
          # via the settings GUI, so left at the v5 default (0 = no outline).
          capsule_border = "primary";
          capsule_padding = 8.0;
          # Old marginVertical/marginHorizontal = 4/4 — v5 defaults to a large
          # inset ("floating pill" look); shrink back to an edge-to-edge bar.
          margin_ends = 4;
          margin_edge = 4;

          start = [
            "launcher"
            "workspaces"
            "active_window"
          ];
          center = [ "media" ];
          end = [
            "sysmon-cpu"
            "sysmon-cpu-temp"
            "sysmon-ram"
            "battery"
            "bluetooth"
            "network"
            "notifications"
            "volume"
            "tray"
            "weather"
            "clock"
            "control-center"
          ];
        };

        widget = {
          active_window = {
            max_length = 400;
            # v5 default changed from the old "on hover" scrolling to "none".
            title_scroll = "on_hover";
          };

          media = {
            artist_first = true;
            max_length = 500;
            title_scroll = "on_hover";
            # v5 default is to keep showing the widget with no media; the old
            # MediaMini hid itself instead.
            hide_when_no_media = true;
          };

          # The old single combo "SystemMonitor" widget (CPU%, CPU temp, RAM used)
          # has no v5 equivalent — each sysmon widget now shows exactly one stat.
          "sysmon-cpu" = {
            type = "sysmon";
            stat = "cpu_usage";
          };
          "sysmon-cpu-temp" = {
            type = "sysmon";
            stat = "cpu_temp";
          };
          "sysmon-ram" = {
            type = "sysmon";
            stat = "ram_used";
          };

          battery = {
            device = "hidpp_battery_0";
            display_mode = "glyph";
          };

          tray = {
            drawer = false;
            # v5 defaults hide_passive to true; the old config explicitly kept
            # passive tray icons visible.
            hide_passive = false;
          };

          # Old Volume.middleClickCommand is now the generic widget-actions
          # system, available on every widget rather than just Volume.
          volume.actions.middle = "exec pwvucontrol || pavucontrol";
        };

        # kenn/keybind-cheatsheet is the v5 rewrite of the old keybind-cheatsheet
        # plugin — it parses hyprland.lua directly, matching the numbered
        # "-- 1. Section" comment convention already used in binds.lua. The
        # official/community plugin sources ship built in, no need to declare them.
        plugins.enabled = [ "kenn/keybind-cheatsheet" ];
      };
    };

  };
}
