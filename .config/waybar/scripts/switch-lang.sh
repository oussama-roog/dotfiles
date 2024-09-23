#!/bin/bash

# Define your layouts here
layouts=("us" "ar")

# Get the current layout
current_layout=$(setxkbmap -query | grep layout: | awk '{print $2}')

echo "Current layout detected: $current_layout"  # Debugging line

# Check if the current layout is among the ones defined
if [[ ! " ${layouts[@]} " =~ " ${current_layout} " ]]; then
  echo "Current layout not found in layouts list."
  exit 1
fi

# Find the index of the current layout
current_index=$(printf "%s\n" "${layouts[@]}" | grep -n "^${current_layout}$" | cut -d: -f1)

# Calculate the next index
next_index=$(( (current_index % ${#layouts[@]}) ))
next_layout=${layouts[$next_index]}

# Apply the new layout
setxkbmap -layout $next_layout

# Optionally, notify the user of the change
# Uncomment if you have notify-send installed and configured
# notify-send "Keyboard layout changed to $next_layout"
