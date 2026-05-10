# vim: set ft=nix ts=2 sw=2 sts=2 et:
{ config, lib, pkgs, ... }:
let
  restart-noctalia = pkgs.writeShellScriptBin "restart-noctalia" ''
    pkill -f noctalia-shell || true
    sleep 0.3
    exec noctalia-shell
  '';
in
{
  config = lib.mkIf (config.myConfig.desktop.shell == "noctalia") {

    home.packages = [ restart-noctalia ];

    programs.noctalia-shell = {
      enable = true;

      plugins = {
        sources = [
          {
            enabled   = true;
            name      = "Noctalia Plugins";
            url       = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          "keybind-cheatsheet" = {
            enabled   = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };

      settings = {
        colorSchemes = {
          predefinedScheme   = "Catppuccin";
          darkMode           = true;
          useWallpaperColors = false;
          syncGsettings      = false;
        };

        bar = {
          position           = "top";
          displayMode        = "always_visible";
          density            = "comfortable";
          showOutline        = true;
          showCapsule        = true;
          capsuleOpacity     = 1;
          useSeparateOpacity = true;
          backgroundOpacity  = 0.00;
          marginVertical     = 4;
          marginHorizontal   = 4;
          widgets = {
            left = [
              { id = "Launcher"; }
              { id = "Workspace"; }
              { id = "ActiveWindow"; maxWidth = 400; useFixedWidth = false; }
            ];
            center = [
              { id = "MediaMini"; maxWidth = 500; useFixedWidth = false; }
            ];
            right = [
              { id = "Clock"; }
              { id = "Tray"; drawerEnabled = false; hidePassive = false; colorizeIcons = false; }
              { id = "NotificationHistory"; }
              { id = "Bluetooth"; }
              { id = "Network"; }
              { id = "Volume"; middleClickCommand = "pwvucontrol || pavucontrol"; }
              { id = "ControlCenter"; }
            ];
          };
        };

        dock.enabled = false;

        wallpaper = {
          enabled   = true;
          directory = "${config.home.homeDirectory}/Pictures/wallpapers";
          fillMode  = "crop";
        };

        idle = {
          enabled          = true;
          lockTimeout      = 660;
          screenOffTimeout = 600;
          suspendTimeout   = 0;
        };

        general = {
          avatarImage                   = "${config.home.homeDirectory}/.face";
          showScreenCorners             = true;
          forceBlackScreenCorners       = true;
          lockScreenAnimations          = true;
          enableLockScreenMediaControls = true;
          clockFormat                   = "HH:mm ";
          lockScreenMonitors            = [ "DP-1" ];
          lockScreenBlur                = 0.8;
          telemetryEnabled              = false;
          showChangelogOnStartup        = false;
          keybinds = {
            keyUp     = [ "Up"   "Ctrl+P" ];
            keyDown   = [ "Down" "Ctrl+N" ];
            keyEscape = [ "Esc"  "Ctrl+[" ];
          };
        };

        ui = {
          fontDefault            = "DejaVu Sans";
          panelBackgroundOpacity = 0.85;
          settingsPanelMode      = "centered";
        };

        osd = {
          backgroundOpacity = 0.85;
        };

        sessionMenu = {
          countdownDuration  = 5000;
          largeButtonsLayout = "grid";
        };

        location = {
          autoLocate = false;
        };

        network = {
          networkPanelView = "ethernet";
        };
      };
    };

  };
}
