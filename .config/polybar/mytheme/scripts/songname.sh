#!/usr/bin/env bash

# Get the currently playing title from Spotify
title=$(playerctl -p spotify metadata title 2>/dev/null)

# Default message if no title is retrieved
if [ -n "$title" ]; then
    echo "$title"
else
    echo "No media playing"
fi
