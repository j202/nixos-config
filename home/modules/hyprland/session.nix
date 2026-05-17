# vim: set ft=nix ts=2 sw=2 sts=2 et:
{
  config,
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
in
{
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
}
