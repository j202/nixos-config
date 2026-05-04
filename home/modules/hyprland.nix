# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Hyprland-specific home configuration — WM, bar, lock, wallpaper.
{ config, lib, pkgs, ... }:
let
  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;

  palette    = builtins.fromJSON (builtins.readFile (config.catppuccin.sources.palette + "/palette.json"));
  c          = builtins.mapAttrs (_: v: v.hex) palette.${flavor}.colors;
  flavorName = (lib.toUpper (lib.substring 0 1 flavor)) + (lib.substring 1 (lib.stringLength flavor - 1) flavor);
in
{
  catppuccin.hyprland.enable = true;
  catppuccin.waybar.enable = true;
  catppuccin.mako.enable = true;
  catppuccin.cursors.enable = true;

  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "menu:";



  gtk = {
    enable = true;
    theme = {
      name    = "catppuccin-${flavor}-${accent}-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = flavor;
        accents = [ accent ];
      };
    };
    iconTheme = {
      name    = "Papirus-Dark";
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

  home.packages = with pkgs; [
    cliphist
    hyprpaper
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

      exec-once = [
        "hyprpaper"
        "bash -c 'while ! hyprctl hyprpaper listactive >/dev/null 2>&1; do sleep 0.1; done; hyprctl hyprpaper wallpaper \"DP-1,${config.home.homeDirectory}/Pictures/wallpaper.jpg\"; hyprctl hyprpaper wallpaper \"DP-4,${config.home.homeDirectory}/Pictures/wallpaper.jpg\"'"
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
        active_opacity   = 0.85;
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
        "$mod CTRL, L, exec, hyprlock"
        "$mod SHIFT, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod SHIFT, M, exec, wlogout"
        ", Print, exec, grimblast copysave area"
        "$mod, Print, exec, grimblast copysave active"
        "$mod SHIFT, Print, exec, grimblast copysave output"
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

  # ── Waybar ────────────────────────────────────────────────────────────────

  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 34;
      spacing = 4;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [];
      modules-right  = [ "wireplumber" "network" "cpu" "memory" "tray" "clock" ];

      "hyprland/workspaces" = {
        format = "{id}";
        on-click = "activate";
        sort-by-number = true;
      };

      "hyprland/window" = {
        max-length = 60;
      };

      "clock" = {
        format = "{:%H:%M  %a %d %b}";
        format-alt = "{:%A, %d %B %Y}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      "cpu" = {
        format = "󰘚  {usage}%";
        interval = 2;
        tooltip = false;
      };

      "memory" = {
        format = "󰍛  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
      };

      "network" = {
        format-ethernet = "󰈀  {ifname}";
        format-wifi = "  {essid}";
        format-disconnected = "󰖪 ";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      "wireplumber" = {
        format = "{icon}  {volume}%";
        format-muted = "󰝟 ";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click = "pwvucontrol";
        scroll-step = 5;
      };

      "tray" = { spacing = 8; };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
          background-color: transparent;
          background-image: linear-gradient(
            to bottom,
            alpha(@base, 0) 0px,
            alpha(@base, 1) 17px,
            @accent         17px,
            @accent         18px,
            alpha(@base, 1) 18px,
            alpha(@base, 0) 100%
          );
          color: @text;
      }

      #workspaces button {
        padding: 0 6px;
        background: @base;
        color: @subtext0;
        border-radius: 4px;
        border: 1px solid @accent;
        margin: 3px 2px;
        transition: background 0.15s;
      }
      #workspaces button:hover { background: @surface0; color: @text; }
      #workspaces button.active { background: @accent; color: @base; font-weight: bold; }
      #workspaces button.urgent { background: @red; color: @base; }

      #window { color: @subtext1; background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }

      #clock {
        color: @accent;
        background-color: @base; 
        border: 1px solid @accent; 
        border-radius: 16px;
        font-weight: bold;
        font-size: 16px;
        margin: 4px 0;
        padding: 0 8px;
      }

      #cpu     { color: @green; background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }
      #memory  { color: @blue;  background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }
      #network { color: @sky;   background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }

      #wireplumber       { color: @pink;     background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }
      #wireplumber.muted { color: @overlay0; background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }

      #tray { background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }
      #tray > .passive        { -gtk-icon-effect: dim; }
      #tray > .needs-attention { -gtk-icon-effect: highlight; background-color: @red; }
    '';
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
          blur_passes = 2;      # Number of blur passes
          blur_size = 5;        # Blur radius
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
    exec = "imv %F";
    mimeType = [
      "image/jpeg" "image/png" "image/gif" "image/webp"
      "image/svg+xml" "image/bmp" "image/tiff" "image/heif"
      "image/avif" "image/jxl"
    ];
    categories = [ "Graphics" "Viewer" ];
    noDisplay = false;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg"                = "imv.desktop";
      "image/png"                 = "imv.desktop";
      "image/gif"                 = "imv.desktop";
      "image/webp"                = "imv.desktop";
      "image/svg+xml"             = "imv.desktop";
      "image/bmp"                 = "imv.desktop";
      "image/tiff"                = "imv.desktop";
      "inode/directory"           = "thunar.desktop";
      "text/plain"                = "org.gnome.gedit.desktop";
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

  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-dark-theme-variant"  = "catppuccin-${flavor}";
  dconf.settings."org/gnome/gedit/preferences/editor"."style-scheme-for-light-theme-variant" = "catppuccin-${flavor}";

  # ── Hyprpaper ─────────────────────────────────────────────────────────────
  # Set WALLPAPER to the path of your wallpaper file.

  services.hyprpaper = {
    enable = true;
    package = null;
    settings = {
      ipc = "on";
      splash = false;
    };
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
