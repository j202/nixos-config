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
        # Steam (and a Steam Link client streaming it) waits for this wrapper
        # to exit before it considers the game closed — running the backup
        # here directly left the stream on a black screen for however long
        # the upload took (~18s, measured). Steam can also kill stray child
        # processes once it decides the game has exited, so backgrounding the
        # backup from here isn't enough either — it needs to never be a
        # descendant of this process at all. So just queue it and exit
        # immediately: game-backup-trigger.path (below) watches the queue
        # directory independently of Steam's process tree and drains it after
        # this wrapper is already gone. Written to tmp/ first and moved into
        # pending/ so the path unit (and the drain loop) only ever see a
        # fully-written entry, never a half-written one; a fresh filename per
        # entry (rather than one shared file) means a second game closing
        # before the first is drained queues alongside it instead of
        # clobbering it.
        # Logged here (rather than assumed silent-success) since this is the
        # one step with no `set -e` protecting it — a failure here would
        # otherwise leave no journal trail at all, just saves that quietly
        # stop getting backed up.
        display_name="''${game_name:-<unknown>}"
        queue_dir="$HOME/.cache/game-backup-queue"
        if mkdir -p "$queue_dir/tmp" "$queue_dir/pending" \
          && entry="$(mktemp "$queue_dir/tmp/XXXXXX")" \
          && printf '%s' "''${game_name}" > "$entry" \
          && mv "$entry" "$queue_dir/pending/$(basename "$entry")"; then
          logger --tag game-save-backup --priority user.info "steam wrapper: queued backup for game='$display_name'"
        else
          logger --tag game-save-backup --priority user.err "steam wrapper: failed to queue backup for game='$display_name'"
        fi
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
        # Same reason as the Steam wrapper: queue instead of running inline,
        # so Lutris isn't left waiting on the backup/upload before it
        # considers the game closed — see the comment there for why this is
        # a queue directory rather than just running/backgrounding it here,
        # and why this step in particular is logged explicitly.
        resolved_name="''${GAME_NAME:-''${game_name:-}}"
        display_name="''${resolved_name:-<unknown>}"
        queue_dir="$HOME/.cache/game-backup-queue"
        if mkdir -p "$queue_dir/tmp" "$queue_dir/pending" \
          && entry="$(mktemp "$queue_dir/tmp/XXXXXX")" \
          && printf '%s' "$resolved_name" > "$entry" \
          && mv "$entry" "$queue_dir/pending/$(basename "$entry")"; then
          logger --tag game-save-backup --priority user.info "lutris trigger: queued backup for game='$display_name'"
        else
          logger --tag game-save-backup --priority user.err "lutris trigger: failed to queue backup for game='$display_name'"
        fi
      '';
    };
  };

  systemd.user = {
    services = {
      # Refreshes the Ludusavi manifest once a day, independent of whether or
      # which games get played — avoids that (occasionally slow) network check
      # ever happening at game-close time, without needing any launcher-specific
      # hook (Steam's cgroup teardown and Lutris's pre-launch process tracking
      # both made per-launcher approaches more complicated than this). Persistent
      # means a missed day (machine off) just runs at the next opportunity,
      # matching the existing flake-update timer's pattern in home/alex.nix.
      # game-backup-run.sh waits on the same lock before reading the manifest
      # itself, since Ludusavi doesn't write it atomically.
      game-manifest-update = {
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

      # Drains ~/.cache/game-backup-queue/pending, queued by the Steam wrapper /
      # Lutris trigger script above rather than run directly by either of them —
      # see the comment in the Steam wrapper for why. Loops rather than handling
      # just one entry so a backlog (e.g. two games closed in quick succession)
      # gets fully processed in one go; each entry is only removed after
      # game-backup-run.sh has finished with it, and a failure on one entry
      # doesn't stop the rest from being processed.
      game-backup-trigger = {
        Unit.Description = "Drain queued game-save backups";
        Service = {
          Type = "oneshot";
          ExecStart = toString (
            pkgs.writeShellScript "game-backup-trigger-run" ''
              queue_dir="$HOME/.cache/game-backup-queue/pending"
              found=0
              for entry in "$queue_dir"/*; do
                [ -e "$entry" ] || continue
                found=1
                game_name="$(cat "$entry" 2> /dev/null || true)"
                display_name="''${game_name:-<unknown>}"
                logger --tag game-save-backup --priority user.info "trigger: draining entry for game='$display_name'"
                "$HOME/.local/bin/game-backup-run.sh" "$game_name" || true
                rm -f "$entry"
              done
              # A spurious/duplicate DirectoryNotEmpty firing (e.g. two changes
              # collapsed into one wakeup) would otherwise look identical to this
              # service just not running — worth a line either way.
              if [ "$found" -eq 0 ]; then
                logger --tag game-save-backup --priority user.info "trigger: fired with nothing queued"
              fi
            ''
          );
        };
      };
    };

    timers.game-manifest-update = {
      Unit.Description = "Daily Ludusavi manifest refresh";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # DirectoryNotEmpty fires on the empty-to-non-empty transition, which is
    # exactly "a new entry showed up" — this is inotify-driven (no polling) and
    # sits idle at zero cost between triggers.
    paths.game-backup-trigger = {
      Unit.Description = "Watch for queued game-save backups";
      Path.DirectoryNotEmpty = "${config.home.homeDirectory}/.cache/game-backup-queue/pending";
      Install.WantedBy = [ "paths.target" ];
    };
  };
}
