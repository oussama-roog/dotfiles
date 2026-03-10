#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

if maim -s "$FILENAME" 2>/dev/null; then
    xclip -selection clipboard -t image/png < "$FILENAME"
    notify-send "Screenshot" "Saved to $FILENAME and copied to clipboard" -i "$FILENAME"
else
    # Fallback: full screen capture if selection cancelled
    if maim "$FILENAME" 2>/dev/null; then
        xclip -selection clipboard -t image/png < "$FILENAME"
        notify-send "Screenshot" "Full screen saved to $FILENAME and copied to clipboard" -i "$FILENAME"
    else
        notify-send "Screenshot" "Failed" -u critical
    fi
fi
