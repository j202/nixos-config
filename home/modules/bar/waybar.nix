# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
  lib,
  ...
}:
let
  flavor = config.catppuccin.flavor;
  palette = builtins.fromJSON (
    builtins.readFile (config.catppuccin.sources.palette + "/palette.json")
  );
  c = builtins.mapAttrs (_: v: v.hex) palette.${flavor}.colors;
in
{
  config = lib.mkIf (config.myConfig.desktop.shell == "waybar") {

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = [
        {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 4;

          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-center = [ "mpris" ];
          modules-right = [
            "wireplumber"
            "network"
            "cpu"
            "memory"
            "tray"
            "clock"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
            sort-by-number = true;
          };

          "hyprland/window" = {
            max-length = 60;
            separate-outputs = false;
          };

          "mpris" = {
            format = "{status_icon}  {artist} – {title}";
            format-stopped = "";
            status-icons = {
              playing = "▶";
              paused = "󰏤";
              stopped = "󰓛";
            };
            max-length = 60;
            tooltip-format = "{album}\n{player}";
            on-click = "playerctl play-pause";
            on-scroll-up = "playerctl next";
            on-scroll-down = "playerctl previous";
            interval = 1;
          };

          "clock" = {
            format = "{:%H:%M  %a %d %b}";
            format-alt = "{:%A, %d %B %Y}";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              weeks-pos = "right";
              format = {
                months = "<span color='${c.mauve}'><b>{}</b></span>";
                weekdays = "<span color='${c.lavender}'><b>{}</b></span>";
                weeks = "<span color='${c.teal}'> W{}</span>";
                days = "<span color='${c.text}'>{}</span>";
                today = "<span color='${c.peach}'><b><u>{}</u></b></span>";
              };
            };
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
            format-wifi = "󰖩  {essid}";
            format-disconnected = "󰖪 ";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          "wireplumber" = {
            format = "{icon}  {volume}%";
            format-muted = "󰝟 ";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "pwvucontrol";
            scroll-step = 5;
          };

          "tray" = {
            spacing = 8;
          };

          "custom/power" = {
            format = "󰐥";
            on-click = "wlogout";
            tooltip = false;
          };
        }
      ];

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
        }

        tooltip {
          background-color: @mantle;
          border: 1px solid @accent;
          border-radius: 8px;
        }
        tooltip label {
          color: @text;
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

        #mpris        { color: @mauve;    background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 10px; }
        #mpris.paused { color: @overlay1; background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 10px; }

        #tray { background-color: @base; border: 1px solid @accent; border-radius: 16px; margin: 4px 0; padding: 0 8px; }
        #tray > .passive        { -gtk-icon-effect: dim; }
        #tray > .needs-attention { -gtk-icon-effect: highlight; background-color: @red; }

        #custom-power {
          color: @red;
          background-color: @base;
          border: 1px solid @accent;
          border-radius: 16px;
          margin: 4px 0;
          padding: 0 10px;
          font-size: 16px;
          transition: background 0.15s;
        }
        #custom-power:hover { background-color: @red; color: @base; }
      '';
    };

    services.mako = {
      enable = true;
      settings = {
        border-radius = 8;
        default-timeout = 5000;
        ignore-timeout = 1;
        on-button-left = "invoke-default-action";
      };
    };

  };
}
