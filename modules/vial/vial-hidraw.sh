# shellcheck shell=bash
# ACTION (grant|revoke) and VIAL_KEYBOARD_IDS are exported by the nix wrappers.
: "${ACTION:?ACTION must be set by the nix wrapper (grant or revoke)}"
: "${VIAL_KEYBOARD_IDS:?VIAL_KEYBOARD_IDS must be set by the nix wrapper}"

matches_keyboard() {
  local dev="${1}" props vid pid
  props=$(udevadm info --query=property "${dev}" 2> /dev/null) || return 1
  vid=$(printf '%s' "${props}" | grep '^ID_VENDOR_ID=' | cut -d= -f2 || true)
  pid=$(printf '%s' "${props}" | grep '^ID_MODEL_ID=' | cut -d= -f2 || true)
  local -a ids
  read -ra ids <<< "${VIAL_KEYBOARD_IDS}"
  for id in "${ids[@]}"; do
    local check_vid check_pid
    check_vid="${id%%:*}"
    check_pid="${id##*:}"
    [ "${vid}" = "${check_vid}" ] && [ "${pid}" = "${check_pid}" ] && return 0
  done
  return 1
}

user_name=$(id -un "${PKEXEC_UID}")
for dev in /dev/hidraw*; do
  if matches_keyboard "${dev}"; then
    case "${ACTION}" in
    grant) setfacl -m "u:${user_name}:rw" "${dev}" || true ;;
    revoke) setfacl -x "u:${user_name}" "${dev}" 2> /dev/null || true ;;
    esac
  fi
done
