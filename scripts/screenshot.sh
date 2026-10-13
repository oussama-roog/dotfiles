#!/usr/bin/env bash
# Region screenshot for niri: drag an area with slurp, grim captures it, the
# png is saved to ~/Pictures/screenshots and copied to the clipboard (where the
# cliphist image watcher picks it up). Esc / right-click cancels quietly.

set -u

dir="$HOME/Pictures/screenshots"
mkdir -p "$dir"

# A second Print while selecting would stack another slurp on top.
pgrep -x slurp >/dev/null && exit 0

geom=$(slurp -d -b '#00000066' -c '#ffffffcc' -s '#ffffff12' -w 2) || exit 0
[ -n "$geom" ] || exit 0

file="$dir/screenshot_$(date +%Y%m%d_%H%M%S).png"

if grim -g "$geom" "$file"; then
    wl-copy --type image/png < "$file"
    notify-send -a Screenshot -i "$file" "Screenshot" "Saved to ${file/#$HOME/\~} and copied"
else
    notify-send -a Screenshot -u critical "Screenshot" "Capture failed"
fi
