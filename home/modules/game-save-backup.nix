# vim: set ft=nix ts=2 sw=2 sts=2 et:
# Game save backups: Ludusavi collects saves, then syncs them to Google Drive.
# The backup itself is triggered after a game session ends (Steam
# launch-option wrapper / Lutris post-exit script), not on a timer — this
# machine is only on while it's being played. The manifest refresh is on a
# daily timer instead (see below), independent of that. See nixos-config's
# ludusavi/config.yaml for the actual backup scope (custom Civ VI rule,
# staging path, etc.).
{
  config,
  pkgs,
  ...
}:
let
  gameBackupRun = pkgs.writeShellApplication {
    name = "game-backup-run";
    runtimeInputs = [
      pkgs.ludusavi
      pkgs.jq
      pkgs.libnotify
      pkgs.util-linux # logger, for step-timing sent to the journal
    ];
    text = builtins.readFile ./game-backup-run.sh;
  };
in
{
  xdg.configFile."ludusavi/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/ludusavi/config.yaml";

  home.file = {
    ".local/bin/game-backup-run.sh" = {
      source = "${gameBackupRun}/bin/game-backup-run";
      executable = true;
    };

    # Steam launch option: always prepend this to whatever's already set.
    # e.g. Clair Obscur's current launch option is:
    #   SteamDeck=0 ENABLE_VKBASALT=1 %command%
    # becomes:
    #   ~/.local/bin/game-backup-steam-wrapper.sh SteamDeck=0 ENABLE_VKBASALT=1 %command%
    ".local/bin/game-backup-steam-wrapper.sh" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        # Same fix as game-backup-run.sh: Steam's own LD_LIBRARY_PATH shadows
        # the correct Nix-provided libraries, which made `ludusavi find`
        # below crash with a symbol lookup error (confirmed via logging) —
        # silently falling back to backing up every game instead of just
        # this one, since its output was never valid JSON to begin with.
        unset LD_LIBRARY_PATH

        # Resolve which game this is while Steam's own env vars are still
        # around, so game-backup-run.sh can back up just this one game
        # instead of every configured game. --no-manifest-update: `find` also
        # checks for manifest updates over the network otherwise, which can
        # occasionally add a large, unpredictable delay.
        game_name="$(ludusavi --no-manifest-update find --steam-id "''${SteamAppId:-}" --backup --api 2>/dev/null | jq -r '.games | keys[0] // empty')"
        # `env "$@"` (rather than a bare "$@") means leading NAME=value tokens
        # from any existing env-var-prefix launch options still get applied
        # correctly regardless of position, so this wrapper always goes at the
        # very front — no per-game placement rules to remember.
        env "$@"
        "$HOME/.local/bin/game-backup-run.sh" "''${game_name}"
      '';
    };

    # Lutris "Post-exit script" field (e.g. Diablo II: Resurrected) — Lutris has
    # already waited for the game to exit by the time this runs, so no wrapping
    # needed here, just the backup itself.
    ".local/bin/game-backup-trigger.sh" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        # Lutris's postexit_command is spawned via GLib's argv-based spawn, not
        # a real shell — unlike Steam's launch options (run through `sh -c`),
        # there's no shebang-less ENOEXEC-to-shell fallback here, so this needs
        # an explicit shebang or Lutris silently fails to exec it at all.
        # Lutris provides the game's title via GAME_NAME (renamed from an
        # earlier lowercase game_name — check both for safety) to post-exit
        # scripts, so this generalizes to any Lutris game, not just one.
        "$HOME/.local/bin/game-backup-run.sh" "''${GAME_NAME:-''${game_name:-}}"
      '';
    };
  };

  # Refreshes the Ludusavi manifest once a day, independent of whether or
  # which games get played — avoids that (occasionally slow) network check
  # ever happening at game-close time, without needing any launcher-specific
  # hook (Steam's cgroup teardown and Lutris's pre-launch process tracking
  # both made per-launcher approaches more complicated than this). Persistent
  # means a missed day (machine off) just runs at the next opportunity,
  # matching the existing flake-update timer's pattern in home/alex.nix.
  # game-backup-run.sh waits on the same lock before reading the manifest
  # itself, since Ludusavi doesn't write it atomically.
  systemd.user.services.game-manifest-update = {
    Unit = {
      Description = "Refresh the Ludusavi game-save manifest";
      # The daily timer's Persistent=true catch-up run tends to land right at
      # login/resume-from-suspend (whenever a missed midnight is next caught
      # up on), which is exactly when the X710 NIC (see project_x710_nic
      # memory) is still renegotiating link — so the first attempt reliably
      # fails with "Is your Internet connection down?". Retry a few times
      # rather than just waiting for tomorrow's timer.
      StartLimitIntervalSec = 600;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "30s";
      ExecStart = toString (
        pkgs.writeShellScript "game-manifest-update" ''
          ${pkgs.util-linux}/bin/flock -n "$HOME/.cache/game-backup-manifest-update.lock" ${pkgs.ludusavi}/bin/ludusavi manifest update
        ''
      );
    };
  };

  systemd.user.timers.game-manifest-update = {
    Unit.Description = "Daily Ludusavi manifest refresh";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
