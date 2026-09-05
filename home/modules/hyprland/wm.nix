# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  isNoctalia = config.myConfig.desktop.shell == "noctalia";

  # Was hyprlang's "$mod" — kept as one Nix binding so the mod key still only
  # needs changing in one place.
  mod = "SUPER";

  toLua = lib.generators.toLua { };

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.grimblast
      pkgs.libnotify
      pkgs.xdg-utils
    ];
    text = builtins.readFile ./screenshot.sh;
  };

  cheatsheet = pkgs.writeShellApplication {
    name = "hyprland-cheatsheet";
    runtimeInputs = [
      pkgs.hyprkeys
      pkgs.jq
      pkgs.rofi
    ];
    text = builtins.readFile ./cheatsheet.sh;
  };

  cheatsheetCmd =
    if isNoctalia then
      "noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"
    else
      "hyprland-cheatsheet";
  launcherCmd = if isNoctalia then "noctalia msg panel-toggle launcher" else "rofi -show drun";
  launcherTapCmd =
    if isNoctalia then "noctalia msg panel-toggle launcher" else "pkill rofi || rofi -show drun";
  lockCmd = if isNoctalia then "noctalia msg session lock" else "hyprlock";
  sessionMenuCmd = if isNoctalia then "noctalia msg panel-toggle session" else "wlogout";

  execOnceCommands =
    lib.optional (config.myConfig.desktop.shell == "waybar") "mako"
    ++ lib.optional isNoctalia "noctalia"
    ++ [
      "hyprshell run"
      "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
      "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      "blueman-applet"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "wl-clip-persist --clipboard primary"
    ]
    ++
      lib.optional (config.myConfig.desktop.shell == "waybar")
        "swayidle -w timeout 300 'hyprlock' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'"
    ++ [
      "steam -silent"
      "bash -c 'until dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.kde.StatusNotifierWatcher 2>/dev/null; do sleep 0.2; done; exec vesktop --start-minimized'"
    ];
in
{
  catppuccin.cursors.enable = true;

  home = {
    pointerCursor = {
      enable = true;
      # catppuccin's hyprland module sets HYPRCURSOR_SIZE from this directly (bypassing
      # home-manager's own hyprcursor.enable gate) — keep it in sync with the XCURSOR_SIZE
      # set below via Hyprland's env, or the cursor grows to home-manager's default of 32.
      size = 24;
    };

    packages = with pkgs; [
      cheatsheet
      hyprshell
      screenshot
      pinta
      cliphist
      wl-clip-persist
      imv
      thunar
      thunar-archive-plugin
      tumbler
      file-roller
      gedit
      gvfs
      grimblast
      lxqt.lxqt-policykit
      networkmanagerapplet
      pwvucontrol
      swayidle
    ];
  };

  # ── Hyprland ──────────────────────────────────────────────────────────────

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd = {
      enable = true;
      variables = [ "--all" ];
      # Default extraCommands (stop+start hyprland-session.target) cascades into killing
      # wayland-wm@hyprland.desktop.service itself via BindsTo=graphical-session.target —
      # drop it, dbus-update-activation-environment alone is still applied.
      extraCommands = [ ];
    };

    settings = {
      config = {
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          layout = "dwindle";
          resize_on_border = true;
          col = {
            active_border = lib.generators.mkLuaInline "colors.mauve";
            inactive_border = lib.generators.mkLuaInline "colors.overlay0";
          };
        };

        decoration = {
          rounding = 8;
          active_opacity = 0.85;
          inactive_opacity = 0.85;
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

        animations.enabled = true;

        dwindle.preserve_split = true;

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          vrr = 2; # FreeSync/VRR when fullscreen only
          exit_window_retains_fullscreen = true;
          focus_on_activate = true;
        };

        cursor.no_hardware_cursors = true;

        ecosystem.no_update_news = true;

        input = {
          kb_layout = "gb";
          kb_options = "ctrl:nocaps";
          follow_mouse = 1;
          touchpad.natural_scroll = false;
        };
      };

      # kanshi manages connected monitors; this fallback covers anything it misses.
      monitor = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
        {
          _args = [
            "XCURSOR_THEME"
            "Catppuccin-Mocha-Mauve-Cursors"
          ];
        }
      ];

      curve = [
        {
          _args = [
            "easeOut"
            {
              type = "bezier";
              points = [
                [
                  0.16
                  1
                ]
                [
                  0.3
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeIn"
            {
              type = "bezier";
              points = [
                [
                  0.7
                  0
                ]
                [
                  0.84
                  0
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 4;
          bezier = "easeOut";
          style = "popin 80%";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 4;
          bezier = "easeOut";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 4;
          bezier = "easeOut";
          style = "slide";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 8;
          bezier = "default";
        }
      ];

      window_rule = [
        {
          name = "suppress-maximize";
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          name = "idle-inhibit-fullscreen";
          match.class = ".*";
          idle_inhibit = "fullscreen";
        }
        {
          name = "idle-inhibit-steam-games";
          match.class = "^steam_app_";
          idle_inhibit = "always";
        }
        {
          name = "float-pwvucontrol";
          match.class = "^(pwvucontrol)$";
          float = true;
        }
        {
          name = "float-nm-connection-editor";
          match.class = "^(nm-connection-editor)$";
          float = true;
        }
        {
          name = "pip";
          match.title = "^(Picture-in-Picture)$";
          float = true;
          pin = true;
        }
        {
          name = "opaque-fullscreen-browser";
          match = {
            class = "^brave-browser$";
            fullscreen = true;
          };
          opacity = "1.0 override 1.0 override";
        }
      ]
      ++ lib.optional isNoctalia {
        name = "float-noctalia-settings";
        match.class = "dev.noctalia.Noctalia";
        float = true;
        size = [
          1080
          920
        ];
      };

      # Recommended by noctalia's own Hyprland-Lua docs: blur its bar/panels/
      # notifications and skip Hyprland's layer animations for them, since
      # noctalia animates those surfaces itself.
      layer_rule = lib.optional isNoctalia {
        name = "noctalia";
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
        no_anim = true;
        ignore_alpha = 0.5;
        blur = true;
        blur_popups = true;
      };
    };

    # binds.lua is a real, static Lua file (home/modules/hyprland/binds.lua) — the
    # only Nix-dependent bits (mod key, noctalia-conditional commands, autostart
    # list) live in vars.lua, which it pulls in via require("vars").
    extraLuaFiles = {
      "vars.lua" = {
        autoLoad = false; # pulled in by binds.lua's own require("vars")
        content = ''
          return {
            mod = ${toLua mod},
            cheatsheet_cmd = ${toLua cheatsheetCmd},
            launcher_cmd = ${toLua launcherCmd},
            launcher_tap_cmd = ${toLua launcherTapCmd},
            lock_cmd = ${toLua lockCmd},
            session_menu_cmd = ${toLua sessionMenuCmd},
            restart_noctalia = ${toLua isNoctalia},
            exec_once_commands = ${toLua execOnceCommands},
          }
        '';
      };
      "binds.lua" = {
        autoLoad = true;
        content = ./binds.lua;
      };
    };
  };
}
