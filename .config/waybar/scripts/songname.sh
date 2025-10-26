#!/usr/bin/env bash

# Maximum output length
MAX_LENGTH=25

# Get the title and URL
title=$(playerctl metadata title 2>/dev/null)
url=$(playerctl metadata xesam:url 2>/dev/null)

# Check if there's any media playing
if [ -z "$title" ]; then
    echo "No media playing"
    exit 0
fi

# Determine the prefix based on the URL
if [[ "$url" == *"spotify:"* ]]; then
    output=" $title"
elif [[ "$url" == *"youtube"* ]]; then
    output=" $title"
else
    output="  $title"
fi

# Truncate if exceeds MAX_LENGTH
if [ ${#output} -gt $MAX_LENGTH ]; then
    echo "${output:0:$((MAX_LENGTH))}"
else
    echo "$output"
fi
