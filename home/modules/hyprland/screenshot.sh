# shellcheck shell=bash
target="${1:-area}"
dir="${HOME}/Pictures/Screenshots"
file="${dir}/$(date +%Y-%m-%d_%H-%M-%S).png"
grimblast copysave "${target}" "${file}"
action=$(notify-send --wait -A "default=Open folder" -i "${file}" "Screenshot" "$(basename "${file}")" || true)
if [[ "${action}" == "default" ]]; then
  xdg-open "${dir}"
fi
