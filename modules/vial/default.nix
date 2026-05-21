# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Vial keyboard configuration — two independent access mechanisms:
#
# 1. BROWSER (WebHID) — udev rule tags each keyboard device with "uaccess",
#    granting the active session user read/write access permanently while
#    logged in. The browser (Brave) shows its own device-picker prompt when
#    the Vial web app first requests access. No manual steps required.
#
# 2. DESKTOP APP — polkit-authenticated wrapper around the `vial` binary.
#    Launching `vial` prompts for your password via pkexec, grants hidraw
#    access for the session, then automatically revokes it when Vial closes.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myConfig.vial;

  keyboardIds = lib.concatMapStringsSep " " (kb: "${kb.vendorId}:${kb.productId}") cfg.keyboards;

  # ── Desktop app helpers ────────────────────────────────────────────────────

  vial-hidraw-grant = pkgs.writeShellApplication {
    name = "vial-hidraw-grant";
    runtimeInputs = [
      pkgs.acl
      pkgs.systemd
    ];
    text = ''
      export VIAL_KEYBOARD_IDS="${keyboardIds}"
      export ACTION=grant
    ''
    + builtins.readFile ./vial-hidraw.sh;
  };

  vial-hidraw-revoke = pkgs.writeShellApplication {
    name = "vial-hidraw-revoke";
    runtimeInputs = [
      pkgs.acl
      pkgs.systemd
    ];
    text = ''
      export VIAL_KEYBOARD_IDS="${keyboardIds}"
      export ACTION=revoke
    ''
    + builtins.readFile ./vial-hidraw.sh;
  };

  # Shadows the real vial binary: prompts for password, runs vial, revokes on exit.
  vial-launch = lib.hiPrio (
    pkgs.writeShellApplication {
      name = "vial";
      text = ''
        export VIAL_BIN="${pkgs.vial}/bin/vial"
      ''
      + builtins.readFile ./vial-launch.sh;
    }
  );
in
{
  options.myConfig.vial = {
    enable = lib.mkEnableOption "Vial keyboard configuration";
    keyboards = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Human-readable keyboard name";
            };
            vendorId = lib.mkOption {
              type = lib.types.str;
              description = "USB vendor ID in lowercase hex (e.g. \"4653\")";
            };
            productId = lib.mkOption {
              type = lib.types.str;
              description = "USB product ID in lowercase hex (e.g. \"0004\")";
            };
          };
        }
      );
      default = [ ];
      description = "Keyboards to grant Vial hidraw access to";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Browser (WebHID) ──────────────────────────────────────────────────────
    # Assigns keyboard hidraw devices to the "vial" group (MODE 0660), so any
    # user in that group has permanent access while the keyboard is plugged in.
    # Scoped to the exact VID/PID of each keyboard.
    users.groups.vial = { };
    users.users.alex.extraGroups = [ "vial" ];

    services.udev.extraRules = lib.concatMapStringsSep "\n" (
      kb:
      ''KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="${kb.vendorId}", ATTRS{idProduct}=="${kb.productId}", GROUP="vial", MODE="0660"''
    ) cfg.keyboards;

    # ── Desktop app ───────────────────────────────────────────────────────────
    environment.systemPackages = [
      pkgs.vial
      vial-hidraw-grant
      vial-hidraw-revoke
      vial-launch
    ];

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "/run/current-system/sw/bin/vial-hidraw-grant" &&
            subject.isInGroup("users")) {
          return polkit.Result.AUTH_SELF;
        }
      });
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "/run/current-system/sw/bin/vial-hidraw-revoke" &&
            subject.isInGroup("users")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
