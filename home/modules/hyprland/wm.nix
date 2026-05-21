# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  isNoctalia = config.myConfig.desktop.shell == "noctalia";

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.grimblast
      pkgs.libnotify
      pkgs.xdg-utils
    ];
    text = ''
      target="''${1:-area}"
      dir="$HOME/Pictures/Screenshots"
      file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
      grimblast copysave "$target" "$file"
      action=$(notify-send --wait -A "default=Open folder" -i "$file" "Screenshot" "$(basename "$file")" || true)
      if [[ "$action" == "default" ]]; then
        xdg-open "$dir"
      fi
    '';
  };

  cheatsheet = pkgs.writeShellApplication {
    name = "hyprland-cheatsheet";
    runtimeInputs = [
      pkgs.hyprkeys
      pkgs.jq
      pkgs.rofi
    ];
    text = ''
      hyprkeys -b -t -j \
        | jq -r '.[] | try select(.mouse == false and .submap == "") | "\(.mods | if . == "" then "         " else . + " " end)\(.key | ascii_upcase)  →  \(if .dispatcher == "exec" then .arg else .dispatcher + " " + .arg end)"' \
        | rofi -dmenu -i -p " Keybinds" -no-custom
    '';
  };
in
{
  catppuccin.hyprland.enable = true;
  catppuccin.cursors.enable = true;

  home.packages = with pkgs; [
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

  # ── Hyprland ──────────────────────────────────────────────────────────────

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = true;
    systemd.variables = [ "--all" ];

    settings = {
      # kanshi manages connected monitors; this fallback covers anything it misses.
      monitor = [ ",preferred,auto,1" ];

      exec-once =
        lib.optional (config.myConfig.desktop.shell == "waybar") "mako"
        ++ lib.optional isNoctalia "noctalia-shell"
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
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vrr = 2; # FreeSync/VRR when fullscreen only
        exit_window_retains_fullscreen = true;
        focus_on_activate = true;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      ecosystem.no_update_news = true;

      "$mod" = "SUPER";

      windowrule = [
        {
          name = "suppress-maximize";
          "match:class" = ".*";
          suppress_event = "maximize";
        }
        {
          name = "idle-inhibit-fullscreen";
          "match:class" = ".*";
          idle_inhibit = "fullscreen";
        }
        {
          name = "idle-inhibit-steam-games";
          "match:class" = "^steam_app_";
          idle_inhibit = "always";
        }
        {
          name = "float-pwvucontrol";
          "match:class" = "^(pwvucontrol)$";
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
        {
          name = "opaque-fullscreen-browser";
          "match:class" = "^(qutebrowser|brave-browser)$";
          "match:fullscreen" = 1;
          opacity = "1.0 override 1.0 override";
        }
      ];
    };

    extraConfig = ''
      # 1. Launchers
      bind = $mod, Return, exec, kitty #"Terminal"
      bind = $mod, F1,    exec, ${
        if isNoctalia then
          "noctalia-shell ipc call plugin:keybind-cheatsheet toggle"
        else
          "hyprland-cheatsheet"
      } #"Keybind Cheatsheet"
      bind = $mod, slash, exec, ${
        if isNoctalia then
          "noctalia-shell ipc call plugin:keybind-cheatsheet toggle"
        else
          "hyprland-cheatsheet"
      } #"Keybind Cheatsheet"
      bind = $mod, R,  exec, ${
        if isNoctalia then "noctalia-shell ipc call launcher toggle" else "rofi -show drun"
      } #"App Launcher"
      bind = $mod, E,  exec, thunar #"File Manager"
      bind = $mod, W,  exec, qutebrowser  #"Browser"
      bindr = $mod, Super_L, exec, ${
        if isNoctalia then "noctalia-shell ipc call launcher toggle" else "pkill rofi || rofi -show drun"
      } #"App Launcher (tap Super)"
      bindr = $mod, Super_R, exec, ${
        if isNoctalia then "noctalia-shell ipc call launcher toggle" else "pkill rofi || rofi -show drun"
      } #"App Launcher (tap Super)"

      # 2. Task Switcher (Alt+Tab = hyprshell, Super+Tab = rofi window list)
      bind  = $mod,      Tab,   exec, rofi -show window #"Window List (rofi)"

      # 3. Windows
      bind = $mod, Q, killactive  #"Close Window"
      bind = $mod, F, fullscreen, 0 #"Fullscreen"
      bind = $mod, V, togglefloating #"Toggle Float"
      bind = $mod, P, layoutmsg, pseudo      #"Pseudo Tile"
      bind = $mod, S, layoutmsg, togglesplit #"Toggle Split"

      # 4. Focus
      bind = $mod, left,  movefocus, l #"Focus Left"
      bind = $mod, right, movefocus, r #"Focus Right"
      bind = $mod, up,    movefocus, u #"Focus Up"
      bind = $mod, down,  movefocus, d #"Focus Down"
      bind = $mod, h, movefocus, l #"Focus Left (h)"
      bind = $mod, l, movefocus, r #"Focus Right (l)"
      bind = $mod, k, movefocus, u #"Focus Up (k)"
      bind = $mod, j, movefocus, d #"Focus Down (j)"

      # 5. Move Windows
      bind = $mod SHIFT, left,  movewindow, l #"Move Left"
      bind = $mod SHIFT, right, movewindow, r #"Move Right"
      bind = $mod SHIFT, up,    movewindow, u #"Move Up"
      bind = $mod SHIFT, down,  movewindow, d #"Move Down"
      bind = $mod SHIFT, h, movewindow, l #"Move Left (h)"
      bind = $mod SHIFT, l, movewindow, r #"Move Right (l)"
      bind = $mod SHIFT, k, movewindow, u #"Move Up (k)"
      bind = $mod SHIFT, j, movewindow, d #"Move Down (j)"

      # 6. Workspaces
      bind = $mod, 1, workspace, 1 #"Workspace 1"
      bind = $mod, 2, workspace, 2 #"Workspace 2"
      bind = $mod, 3, workspace, 3 #"Workspace 3"
      bind = $mod, 4, workspace, 4 #"Workspace 4"
      bind = $mod, 5, workspace, 5 #"Workspace 5"
      bind = $mod, 6, workspace, 6 #"Workspace 6"
      bind = $mod, 7, workspace, 7 #"Workspace 7"
      bind = $mod, 8, workspace, 8 #"Workspace 8"
      bind = $mod, 9, workspace, 9 #"Workspace 9"
      bind = $mod SHIFT, 1, movetoworkspace, 1 #"Send to Workspace 1"
      bind = $mod SHIFT, 2, movetoworkspace, 2 #"Send to Workspace 2"
      bind = $mod SHIFT, 3, movetoworkspace, 3 #"Send to Workspace 3"
      bind = $mod SHIFT, 4, movetoworkspace, 4 #"Send to Workspace 4"
      bind = $mod SHIFT, 5, movetoworkspace, 5 #"Send to Workspace 5"
      bind = $mod SHIFT, 6, movetoworkspace, 6 #"Send to Workspace 6"
      bind = $mod SHIFT, 7, movetoworkspace, 7 #"Send to Workspace 7"
      bind = $mod SHIFT, 8, movetoworkspace, 8 #"Send to Workspace 8"
      bind = $mod SHIFT, 9, movetoworkspace, 9 #"Send to Workspace 9"
      bind = $mod, mouse_down, workspace, e+1 #"Next Workspace"
      bind = $mod, mouse_up,   workspace, e-1 #"Previous Workspace"

      # 7. Utilities
      bind = $mod CTRL,  L,     exec, ${
        if isNoctalia then "noctalia-shell ipc call lockScreen lock" else "hyprlock"
      } #"Lock Screen"
      ${if isNoctalia then ''bind = $mod SHIFT, N, exec, restart-noctalia #"Restart Noctalia"'' else ""}
      bind = $mod SHIFT, C,     exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy #"Clipboard History"
      bind = $mod SHIFT, M,     exec, ${
        if isNoctalia then "noctalia-shell ipc call sessionMenu toggle" else "wlogout"
      } #"Session Menu"
      bind = ,           Print, exec, screenshot area   #"Screenshot Area"
      bind = $mod,       Print, exec, screenshot active #"Screenshot Window"
      bind = $mod SHIFT, Print, exec, screenshot output #"Screenshot Monitor"

      # 8. Media
      bindel = , XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ #"Volume Up"
      bindel = , XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-       #"Volume Down"
      bindel = , XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle      #"Mute"
      bindel = , XF86MonBrightnessUp,   exec, brightnessctl set 5%+  #"Brightness Up"
      bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-  #"Brightness Down"
      bindl  = , XF86AudioPlay,  exec, playerctl play-pause #"Play / Pause"
      bindl  = , XF86AudioNext,  exec, playerctl next       #"Next Track"
      bindl  = , XF86AudioPrev,  exec, playerctl previous   #"Previous Track"

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

    '';
  };
}
