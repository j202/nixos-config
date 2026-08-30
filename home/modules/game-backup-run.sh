# vim: set ft=bash ts=2 sw=2 sts=2 et:
# shellcheck shell=bash
# Takes one optional argument: the specific game that was just played, if
# known (resolved by the caller — see game-backup-steam-wrapper.sh and
# game-backup-trigger.sh). Ludusavi's own game-discovery scan costs roughly
# the same fixed ~20s regardless of how many games are actually installed, so
# scoping to just the one played is the main way to avoid paying that cost
# for every game on every single run. Falls back to backing up everything if
# the game couldn't be identified. Copies a small selection of Civ VI's save
# data in directly (see below, only when Civ VI is the game in question),
# then uploads to Google Drive.
GAME_NAME="${1:-}"

# When launched via Steam, this inherits Steam's own LD_LIBRARY_PATH (set for
# compatibility with the games it launches), which shadows the correct
# Nix-provided libraries for tools like notify-send with older bundled ones —
# causing symbol lookup errors. Only affects this script and its own children.
unset LD_LIBRARY_PATH

notify() {
  local urgency="$1" title="$2" body="$3"
  notify-send --app-name "Game Save Backup" --urgency "${urgency}" "${title}" "${body}" || true
}

# Everything else in this script (the --api JSON, stderr) is deleted in
# on_exit, so without this there's no way to tell after the fact whether a
# slow-feeling run was the local backup or the cloud upload, or why. Goes to
# the journal (not a flat file) so it needs no rotation of its own and shows
# up alongside everything else we already check with journalctl.
log() {
  local priority="$1" msg="$2"
  logger --tag game-save-backup --priority "user.${priority}" "${msg}"
}

# Civ VI: HallofFame.sqlite and Challenges are tracked normally by Ludusavi
# (restorable via `ludusavi restore`). Its save folder isn't tracked — the
# live auto/ folder is kept in full until the next new game starts, too large
# to copy every run — so this copies a small selection in manually: every
# manually-named save, plus turn 1 and the newest autosave, both from auto/
# only (auto/prev/ is a previous game's leftovers). `ludusavi restore` won't
# cover these saves; see README for the manual restore step.
#
# Takes the captured `ludusavi backup --api` JSON and the staging directory.
# Prints a warning (and nothing else) on failure; otherwise silent.
backup_civ6_saves() {
  local backup_json="$1" backup_dir="$2"
  local hof_path saves_dir stage_dir turn1_path latest_path debug_json

  hof_path="$(jq -r '.games["Sid Meier'"'"'s Civilization VI"].files // {} | keys[] | select(test("HallofFame\\.sqlite$"))' "${backup_json}" 2> /dev/null | head -n1)"
  if [ -z "${hof_path}" ]; then
    debug_json="$(dirname "${backup_dir}")/game-save-backup-civ6-debug.json"
    cp "${backup_json}" "${debug_json}" 2> /dev/null
    echo "Could not resolve Civ VI's save folder — its saves were not backed up this run (see ${debug_json})"
    return
  fi

  saves_dir="$(dirname "${hof_path}")/Saves/Single"
  stage_dir="${backup_dir}/Sid Meier's Civilization VI/Saves/Single"
  mkdir -p "${stage_dir}"

  # Manually-named saves (and any stray config files alongside them).
  find "${saves_dir}" -maxdepth 1 -type f \( -iname '*.Civ6Save' -o -iname '*.Civ6Cfg' \) -exec cp -t "${stage_dir}" {} + 2> /dev/null

  # The one small config file paired with the current game's autosaves.
  find "${saves_dir}/auto" -maxdepth 1 -type f -iname '*.Civ6Cfg' -exec cp -t "${stage_dir}" {} + 2> /dev/null

  # Turn 1: lowest AutoSave_NNNN number present. Original filename kept as-is —
  # the number in it already makes which save this is obvious enough.
  turn1_path="$(find "${saves_dir}/auto" -maxdepth 1 -type f -iname 'AutoSave_*.Civ6Save' -printf '%f\t%p\n' 2> /dev/null | sort -t $'\t' -k1,1 -V | head -n1 | cut -f2)"
  if [ -n "${turn1_path}" ]; then
    cp "${turn1_path}" "${stage_dir}/"
  fi

  # Newest: latest modification time.
  latest_path="$(find "${saves_dir}/auto" -maxdepth 1 -type f -iname 'AutoSave_*.Civ6Save' -printf '%T@ %p\n' 2> /dev/null | sort -rn | head -n1 | cut -d' ' -f2-)"
  if [ -n "${latest_path}" ]; then
    cp "${latest_path}" "${stage_dir}/"
  fi
}

SUCCESS=0
FAIL_MSG=""
WARN_MSG=""
BACKUP_JSON=""
UPLOAD_JSON=""
STDERR_LOG=""
SCRIPT_START=${EPOCHSECONDS}

on_exit() {
  # Overwrite the debug output with output from the latest run.
  local debug_dir="${HOME}/.cache/game-save-backup-debug"
  mkdir -p "${debug_dir}"
  cp "${BACKUP_JSON}" "${debug_dir}/latest-backup.json" 2> /dev/null || true
  cp "${UPLOAD_JSON}" "${debug_dir}/latest-upload.json" 2> /dev/null || true
  cp "${STDERR_LOG}" "${debug_dir}/latest-stderr.log" 2> /dev/null || true
  rm -f "${BACKUP_JSON}" "${UPLOAD_JSON}" "${STDERR_LOG}"
  local total=$((EPOCHSECONDS - SCRIPT_START))
  if [ "${SUCCESS}" -eq 1 ]; then
    log info "done game='${GAME_NAME:-<all>}' total=${total}s"
    if [ -n "${WARN_MSG}" ]; then
      notify normal "Game save backup: some files skipped" "${WARN_MSG}"
    else
      notify normal "Game save backup complete" "Saves backed up and uploaded to Google Drive"
    fi
  else
    log err "failed game='${GAME_NAME:-<all>}' total=${total}s: ${FAIL_MSG}"
    notify critical "Game save backup FAILED" "${FAIL_MSG:-see journal for details}"
  fi
}
trap on_exit EXIT

log info "start game='${GAME_NAME:-<all>}'"

# Single source of truth for the staging path is ludusavi/config.yaml's
# backup.path — asked for at runtime rather than duplicated here, so the two
# can never drift out of sync.
BACKUP_DIR="$(ludusavi config show --api | jq -r '.backup.path')"

# Hold this lock for the rest of the script (released automatically when it
# exits and fd 200 closes) — not just a momentary check-and-release, which
# wouldn't protect the actual ludusavi calls below from a manifest update
# starting partway through them. Ludusavi doesn't write the manifest
# atomically, so a concurrent read risks a corrupt read; this also stops the
# daily manifest-update timer (game-manifest-update.service) from starting
# one while we're using it, the same way it stops us from reading mid-write.
exec 200> "${HOME}/.cache/game-backup-manifest-update.lock"
flock 200

# Stderr is kept separate from the --api JSON output below, not merged into
# it — Steam's own environment can print warnings (e.g. LD_PRELOAD notices)
# to stderr around anything it launches, which would otherwise corrupt the
# JSON and make every jq query against it silently fail.
BACKUP_JSON="$(mktemp)"
UPLOAD_JSON="$(mktemp)"
STDERR_LOG="$(mktemp)"

# Only passed through when a specific game was identified by the caller —
# an empty array here means "back up everything", the safe fallback.
GAME_ARGS=()
if [ -n "${GAME_NAME}" ]; then
  GAME_ARGS=("${GAME_NAME}")
fi

# --no-manifest-update: the real cost behind the inconsistent timing this
# whole thing was scoped to fix — Ludusavi periodically checks its community
# manifest for updates over the network, and when that check is due, it adds
# a large, unpredictable delay (measured 50+ seconds in one case) unrelated
# to how much is actually being backed up. We don't need bleeding-edge
# manifest data for this.
# --no-cloud-sync: config.yaml has cloud.synchronize: true, and --cloud-sync
# defers to that config value when not explicitly set — so without this,
# `backup` does its own implicit cloud-conflict check (a dry-run rclone sync)
# as a side effect, entirely redundant with the explicit `cloud upload` call
# below, and a real (if accidental) source of extra time on every run.
backup_start=${EPOCHSECONDS}
if ! ludusavi --no-manifest-update backup --no-cloud-sync --force --api "${GAME_ARGS[@]}" > "${BACKUP_JSON}" 2> "${STDERR_LOG}"; then
  FAIL_MSG="ludusavi backup failed: $(cat "${STDERR_LOG}")"
  exit 1
fi
log info "backup ok in $((EPOCHSECONDS - backup_start))s"

failed_files="$(jq -r '[.games[]?.files? // {} | to_entries[] | select(.value.failed == true) | .key] | join(", ")' "${BACKUP_JSON}" 2> /dev/null || true)"
if [ -n "${failed_files}" ]; then
  WARN_MSG="Could not back up: ${failed_files}"
fi

# Civ VI's save data is only ever included when Civ VI is actually the game
# in question — otherwise its entry isn't in this run's JSON at all, and
# warning about that every time you close an unrelated game would just be
# noise.
if [ -z "${GAME_NAME}" ] || [ "${GAME_NAME}" = "Sid Meier's Civilization VI" ]; then
  civ6_warning="$(backup_civ6_saves "${BACKUP_JSON}" "${BACKUP_DIR}")"
  if [ -n "${civ6_warning}" ]; then
    WARN_MSG="${WARN_MSG:+${WARN_MSG}; }${civ6_warning}"
  fi
fi

upload_start=${EPOCHSECONDS}
if ! ludusavi --no-manifest-update cloud upload --force --api "${GAME_ARGS[@]}" > "${UPLOAD_JSON}" 2> "${STDERR_LOG}"; then
  FAIL_MSG="ludusavi cloud upload failed: $(cat "${STDERR_LOG}")"
  exit 1
fi
log info "cloud upload ok in $((EPOCHSECONDS - upload_start))s"

upload_errors="$(jq -r 'if .errors then (.errors | tostring) else empty end' "${UPLOAD_JSON}" 2> /dev/null || true)"
if [ -n "${upload_errors}" ]; then
  if [ -n "${WARN_MSG}" ]; then
    WARN_MSG="${WARN_MSG}; cloud upload reported errors: ${upload_errors}"
  else
    WARN_MSG="Cloud upload reported errors: ${upload_errors}"
  fi
fi

SUCCESS=1
