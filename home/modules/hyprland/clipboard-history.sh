# shellcheck shell=bash
# Pick a cliphist entry to copy; Alt+d deletes the highlighted one and reopens.
while true; do
  rc=0
  choice=$(cliphist list | rofi -dmenu -p clipboard \
    -kb-custom-1 "Alt+d" \
    -mesg "Enter: copy · Alt+d: delete") || rc=$?
  case "${rc}" in
  0)
    cliphist decode <<< "${choice}" | wl-copy
    break
    ;;
  10) cliphist delete <<< "${choice}" ;;
  *) break ;;
  esac
done
