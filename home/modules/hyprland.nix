# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Hyprland core configuration — WM, lock, wallpaper. Bar lives in bar/.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;

  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  c = builtins.mapAttrs (_: v: v.hex) palette.${flavor}.colors;
  base = palette.${flavor}.colors.base.rgb;
  wlRgba = "rgba(${toString base.r}, ${toString base.g}, ${toString base.b}, 0.88)";
  flavorName =
    (lib.toUpper (lib.substring 0 1 flavor)) + (lib.substring 1 (lib.stringLength flavor - 1) flavor);

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

  imv-open = pkgs.writeShellScriptBin "imv-open" ''
    exec ${pkgs.imv}/bin/imv -n "$(basename "$1")" "$(dirname "$1")"
  '';

  isNoctalia = config.myConfig.desktop.shell == "noctalia";

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

  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "menu:";

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-${flavor}-${accent}-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = flavor;
        accents = [ accent ];
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        inherit flavor accent;
      };
    };
    gtk4.theme = config.gtk.theme;
    gtk3.extraConfig = {
      gtk-decoration-layout = "menu:";
    };
    gtk4.extraConfig = {
      gtk-decoration-layout = "menu:";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  catppuccin.kvantum.enable = true;

  home.packages = with pkgs; [
    cheatsheet
    hyprshell
    imv-open
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
          "proton-pass"
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
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vrr = 2; # FreeSync/VRR when fullscreen only
        exit_window_retains_fullscreen = true;
        focus_on_activate = true;
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
      bind = $mod, P, pseudo      #"Pseudo Tile"
      bind = $mod, S, togglesplit #"Toggle Split"

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
            criteria = "AOC AG405UXC XYCQ2JA000267"; # cspell:ignore XYCQ2JA000267
            mode = "3440x1440@144Hz";
            position = "0,1080";
            status = "enable";
          }
          {
            criteria = "HP Inc. HP E24u G4 CN4139185F";
            mode = "1920x1080@60Hz";
            position = "720,0";
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

  # ── Hyprlock ──────────────────────────────────────────────────────────────

  catppuccin.hyprlock.enable = true;

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

      # Background configuration with blur
      background = [
        {
          # Use "screenshot" for live wallpaper or path to an image file
          path = "${config.home.homeDirectory}/Pictures/wallpaper.jpg";
          blur_passes = 2; # Number of blur passes
          blur_size = 5; # Blur radius
          # Optional: Adjust contrast and brightness for better readability
          contrast = 0.8;
          brightness = 0.8;
        }
      ];
    };
  };

  # ── XDG MIME associations ─────────────────────────────────────────────────

  xdg.desktopEntries.imv = {
    name = "imv";
    genericName = "Image Viewer";
    exec = "${imv-open}/bin/imv-open %f";
    mimeType = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
      "image/heif"
      "image/avif"
      "image/jxl"
    ];
    categories = [
      "Graphics"
      "Viewer"
    ];
    noDisplay = false;
  };

  xdg.configFile."hyprshell/styles.css".text =
    let
      rgba =
        name: alpha:
        let
          col = palette.${flavor}.colors.${name}.rgb;
        in
        "rgba(${toString col.r}, ${toString col.g}, ${toString col.b}, ${alpha})";
    in
    ''
      :root {
        --bg-window-color:     ${rgba "base" "0.92"};
        --bg-color:            ${rgba "surface0" "0.85"};
        --bg-color-hover:      ${rgba "surface1" "0.90"};
        --border-color:        ${rgba "surface2" "0.50"};
        --border-color-active: ${rgba accent "1.0"};
        --text-color:          ${rgba "text" "1.0"};
        --border-radius:       8px;
        --border-size:         2px;
      }
    '';

  xdg.configFile."hyprshell/config.ron".text = ''
    (
      version: 3,
      windows: (
        switch: (
          modifier: "alt",
          key: "Tab",
          filter_by: [],
          switch_workspaces: false,
          exclude_special_workspaces: "",
        ),
        switch_2: None,
        overview: None,
        scale: 8.5,
        items_per_row: 5,
      ),
    )
  '';

  home.file."Pictures/Screenshots/.keep".text = "";
  home.file."Pictures/wallpapers/.keep".text = "";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "inode/directory" = "thunar.desktop";
      "text/plain" = "org.gnome.gedit.desktop";
    };
  };

  # ── Gedit (GtkSourceView colour scheme) ──────────────────────────────────

  xdg.dataFile."libgedit-gtksourceview-300/styles/catppuccin-${flavor}.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <style-scheme id="catppuccin-${flavor}" _name="Catppuccin ${flavorName}" kind="dark">
      <_description>Soothing pastel theme</_description>

      <color name="rosewater" value="${c.rosewater}"/>
      <color name="flamingo"  value="${c.flamingo}"/>
      <color name="pink"      value="${c.pink}"/>
      <color name="mauve"     value="${c.mauve}"/>
      <color name="red"       value="${c.red}"/>
      <color name="maroon"    value="${c.maroon}"/>
      <color name="peach"     value="${c.peach}"/>
      <color name="yellow"    value="${c.yellow}"/>
      <color name="green"     value="${c.green}"/>
      <color name="teal"      value="${c.teal}"/>
      <color name="sky"       value="${c.sky}"/>
      <color name="sapphire"  value="${c.sapphire}"/>
      <color name="blue"      value="${c.blue}"/>
      <color name="lavender"  value="${c.lavender}"/>
      <color name="text"      value="${c.text}"/>
      <color name="subtext1"  value="${c.subtext1}"/>
      <color name="subtext0"  value="${c.subtext0}"/>
      <color name="overlay2"  value="${c.overlay2}"/>
      <color name="overlay1"  value="${c.overlay1}"/>
      <color name="overlay0"  value="${c.overlay0}"/>
      <color name="surface2"  value="${c.surface2}"/>
      <color name="surface1"  value="${c.surface1}"/>
      <color name="surface0"  value="${c.surface0}"/>
      <color name="base"      value="${c.base}"/>
      <color name="mantle"    value="${c.mantle}"/>
      <color name="crust"     value="${c.crust}"/>

      <style name="text"                    foreground="text"     background="base"/>
      <style name="selection"               foreground="crust"    background="mauve"/>
      <style name="cursor"                  foreground="rosewater"/>
      <style name="current-line"            background="surface0"/>
      <style name="line-numbers"            foreground="overlay1" background="mantle"/>
      <style name="current-line-number"     foreground="subtext1" background="mantle"/>
      <style name="draw-spaces"             foreground="surface1"/>
      <style name="bracket-match"           foreground="crust"    background="mauve"  bold="true"/>
      <style name="bracket-mismatch"        foreground="red"                          bold="true"/>
      <style name="right-margin"            foreground="surface0" background="surface0"/>
      <style name="search-match"            foreground="crust"    background="green"/>

      <style name="def:comment"             foreground="overlay0" italic="true"/>
      <style name="def:doc-comment"         foreground="overlay0" italic="true"/>
      <style name="def:doc-comment-element" foreground="overlay0"/>
      <style name="def:constant"            foreground="peach"/>
      <style name="def:string"              foreground="green"/>
      <style name="def:special-char"        foreground="pink"/>
      <style name="def:keyword"             foreground="mauve"/>
      <style name="def:statement"           foreground="mauve"/>
      <style name="def:operator"            foreground="sky"/>
      <style name="def:identifier"          foreground="lavender"/>
      <style name="def:function"            foreground="blue"/>
      <style name="def:type"                foreground="blue"/>
      <style name="def:preprocessor"        foreground="pink"/>
      <style name="def:error"               foreground="red"      underline="true"/>
      <style name="def:warning"             foreground="yellow"/>
      <style name="def:note"                foreground="teal"/>
      <style name="def:number"              foreground="peach"/>
      <style name="def:boolean"             foreground="peach"/>
      <style name="def:variable"            foreground="text"/>
      <style name="def:builtin"             foreground="red"/>
      <style name="def:net-address"         foreground="sky"      underline="true"/>
      <style name="def:heading"             foreground="blue"     bold="true"/>
      <style name="def:list-marker"         foreground="mauve"/>
    </style-scheme>
  '';

  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-dark-theme-variant" =
    "catppuccin-${flavor}";
  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-light-theme-variant" =
    "catppuccin-${flavor}";

  # ── Hyprpaper (waybar only — noctalia manages its own wallpaper) ──────────

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

  # ── Wlogout ───────────────────────────────────────────────────────────────

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "uwsm stop";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
    ];
    style = ''
      * {
        box-shadow: none;
      }

      window {
        background-color: ${wlRgba};
      }

      button {
        color: ${c.text};
        background-color: ${c.surface0};
        border: 2px solid ${c.${accent}};
        border-radius: 12px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: auto 60%;
        padding: 0;
        margin: 8px;
        font-size: 14px;
        font-family: "JetBrainsMono Nerd Font";
        transition: background-color 0.15s ease-in-out, border-color 0.15s ease-in-out;
      }

      button:hover {
        background-color: ${c.surface1};
        border-color: ${c.${accent}};
      }

      button:active, button:active:hover {
        background-color: ${c.${accent}};
        color: ${c.base};
        border-color: ${c.${accent}};
      }

      #lock     { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
      #logout   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
      #suspend  { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
      #hibernate { background-image: url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"); }
      #reboot   { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
      #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
    '';
  };

  # ── VS Code (Wayland keyring) ─────────────────────────────────────────────
  # gnome-libsecret is used for secret storage on non-GNOME Wayland desktops.
  # Plasma has its own equivalent, so this only lives here.
  # Activation script (not home.file) so VS Code can write its own fields.
  home.activation.vscodeArgv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _argv="$HOME/.vscode/argv.json"
    mkdir -p "$(dirname "$_argv")"
    if [ -L "$_argv" ] || [ ! -f "$_argv" ]; then
      rm -f "$_argv"
      printf '{\n  "password-store": "gnome-libsecret"\n}\n' > "$_argv"
    fi
  '';
}
