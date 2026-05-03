# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Hyprland-specific home configuration — WM, bar, lock, wallpaper.
{ config, pkgs, ... }:
{
  catppuccin.hyprland.enable = true;
  catppuccin.waybar.enable = true;
  catppuccin.mako.enable = true;
  catppuccin.cursors.enable = true;

  home.packages = with pkgs; [
    cliphist
    hyprpaper
    hyprshot
    lxqt.lxqt-policykit
    networkmanagerapplet
    swayidle
  ];

  # ── Hyprland ──────────────────────────────────────────────────────────────

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.variables = [ "--all" ];

    settings = {
      # kanshi manages connected monitors; this fallback covers anything it misses.
      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "gnome-keyring-daemon --start --components=secrets"
        "hyprpaper"
        "waybar"
        "mako"
        "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
        "blueman-applet"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "swayidle -w timeout 300 'hyprlock' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Catppuccin-Mocha-Mauve-Cursors"
      ];

      input = {
        kb_layout = "gb";
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOut,0.16,1,0.3,1"
          "easeIn,0.7,0,0.84,0"
        ];
        animation = [
          "windows,1,4,easeOut,popin 80%"
          "fade,1,4,easeOut"
          "workspaces,1,4,easeOut,slide"
          "border,1,8,default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vrr = 2;  # FreeSync/VRR when fullscreen only
      };

      ecosystem.no_update_news = true;

      "$mod" = "SUPER";

      bind = [
        # Launchers
        "$mod, Return, exec, kitty"
        "$mod, R, exec, rofi -show drun"
        "$mod, E, exec, rofi -show run"

        # Windows
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 0"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Move windows
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        # Utilities
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod SHIFT, M, exit,"
        ", Print, exec, hyprshot -m region"
        "$mod, Print, exec, hyprshot -m window"
        "$mod SHIFT, Print, exec, hyprshot -m output"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindl = [
        ", XF86AudioPlay,  exec, playerctl play-pause"
        ", XF86AudioNext,  exec, playerctl next"
        ", XF86AudioPrev,  exec, playerctl previous"
      ];

      windowrule = [
        {
          name = "suppress-maximize";
          "match:class" = ".*";
          suppress_event = "maximize";
        }
        {
          name = "float-pavucontrol";
          "match:class" = "^(pavucontrol)$";
          float = true;
        }
        {
          name = "float-nm-connection-editor";
          "match:class" = "^(nm-connection-editor)$";
          float = true;
        }
        {
          name = "pip";
          "match:title" = "^(Picture-in-Picture)$";
          float = true;
          pin = true;
        }
      ];
    };
  };

  # ── Kanshi (dynamic monitor management) ──────────────────────────────────
  # services.kanshi runs as a systemd user service and starts automatically
  # via graphical-session.target — no exec-once entry needed.

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "dual";
        profile.outputs = [
          {
            criteria = "AOC AG405UXC XYCQ2JA000267";
            mode = "3440x1440@144Hz";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "HP Inc. HP E24u G4 CN4139185F";
            mode = "1920x1080@60Hz";
            position = "3440,0";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "single";
        profile.outputs = [
          {
            criteria = "*";
            status = "enable";
          }
        ];
      }
    ];
  };

  # ── Waybar ────────────────────────────────────────────────────────────────

  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 34;
      spacing = 4;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "pulseaudio" "network" "cpu" "memory" "tray" ];

      "hyprland/workspaces" = {
        format = "{id}";
        on-click = "activate";
        sort-by-number = true;
      };

      "hyprland/window" = {
        max-length = 60;
      };

      "clock" = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %d %B %Y}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      "cpu" = {
        format = "  {usage}%";
        interval = 2;
        tooltip = false;
      };

      "memory" = {
        format = "  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
      };

      "network" = {
        format-ethernet = "󰈀  {ifname}";
        format-wifi = "  {essid}";
        format-disconnected = "󰖪 ";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      "pulseaudio" = {
        format = "{icon}  {volume}%";
        format-muted = "󰝟 ";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      "tray" = { spacing = 8; };
    }];
  };

  # ── Mako (notifications) ──────────────────────────────────────────────────

  services.mako = {
    enable = true;
    settings = {
      border-radius = 8;
      default-timeout = 5000;
      ignore-timeout = 1;
    };
  };

  # ── Hyprlock ──────────────────────────────────────────────────────────────

  catppuccin.hyprlock.enable = true;

  programs.hyprlock = {
    enable = true;
  };

  # ── Hyprpaper ─────────────────────────────────────────────────────────────
  # Set WALLPAPER to the path of your wallpaper file.

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [ ",~/Pictures/wallpaper.jpg" ];
    };
  };
}
