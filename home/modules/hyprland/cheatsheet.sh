# shellcheck shell=bash
# cspell:ignore submap dmenu
hyprkeys -b -t -j |
  jq -r '.[] | try select(.mouse == false and .submap == "") | "\(.mods | if . == "" then "         " else . + " " end)\(.key | ascii_upcase)  →  \(if .dispatcher == "exec" then .arg else .dispatcher + " " + .arg end)"' |
  rofi -dmenu -i -p " Keybinds" -no-custom
