#!/usr/bin/env bash

# Get the currently active player
playerctlstatus=$(playerctl -p spotify status 2>/dev/null)

# Determine if Spotify is playing or not
if [[ $playerctlstatus == "Playing" ]]; then
    echo " %{A1:playerctl pause:}%{A}"
elif [[ $playerctlstatus == "Paused" ]]; then
    echo " %{A1:playerctl play:}%{A}"
else
    echo "󰝚"
fi
