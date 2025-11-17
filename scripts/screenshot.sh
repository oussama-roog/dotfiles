#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

    notify-send "Screenshot" "Saved to $FILENAME and copied to clipboard" -i "$FILENAME"
else
    notify-send "Screenshot" "Failed" -u critical
fi
