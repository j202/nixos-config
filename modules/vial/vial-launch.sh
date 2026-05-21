# shellcheck shell=bash
# VIAL_BIN (path to the real vial binary) is exported by the nix wrapper.
: "${VIAL_BIN:?VIAL_BIN must be set by the nix wrapper}"

pkexec /run/current-system/sw/bin/vial-hidraw-grant
cleanup() { pkexec /run/current-system/sw/bin/vial-hidraw-revoke; }
trap cleanup EXIT
"${VIAL_BIN}" "$@" &
vial_pid=$!
wait "${vial_pid}"
