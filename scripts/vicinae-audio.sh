#!/usr/bin/env bash

declare -A output_map
options=""

# Parse Bluetooth audio devices
while IFS=$'\t' read -r id desc; do
    output_map["$desc"]="$id"
    options+="$desc"$'\n'
done < <(pactl list sinks | awk '
    /^Sink #/ {sink_id=$2; gsub(/#/, "", sink_id)}
    /^\tName:/ && /bluez/ {is_bluez=1}
    /^\tDescription:/ && is_bluez {
        desc=$0
        sub(/^\tDescription: /, "", desc)
        print sink_id "\t" desc
        is_bluez=0
    }
')

# Parse analog audio devices
while IFS=$'\t' read -r sink_id sink_name port_name; do
    display_name="$port_name"
    output_map["$display_name"]="$sink_id:$port_name"
    options+="$display_name"$'\n'
done < <(pactl list sinks | awk '
    /^Sink #/ {sink_id=$2; gsub(/#/, "", sink_id)}
    /^\tName:/ && !/bluez/ {sink_name=$2}
    /^\t\t/ && $0 ~ /^[[:space:]]*[a-z-]+:/ {
        port_name=$1
        gsub(/:$/, "", port_name)
        gsub(/analog-output-/, "", port_name)
        gsub(/-/, " ", port_name)
        port_name=toupper(substr(port_name,1,1)) substr(port_name,2)
        if (sink_name != "" && port_name != "") {
            print sink_id "\t" sink_name "\t" port_name
        }
    }
')

# Use vicinae dmenu to show the options
selection=$(echo -n "$options" | vicinae dmenu --placeholder "Select Audio Output")

if [[ -n "$selection" ]]; then
    output_spec="${output_map[$selection]}"

    # Handle sink with port
    if [[ "$output_spec" =~ ^([0-9]+):(.+)$ ]]; then
        sink_id="${BASH_REMATCH[1]}"
        port_name="${BASH_REMATCH[2]}"
        port_name=$(echo "$port_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        port_name="analog-output-${port_name}"
        pactl set-default-sink "$sink_id" && pactl set-sink-port "$sink_id" "$port_name" && notify-send "Audio Output" "Switched to: $selection"
    else
        # Handle Bluetooth sink
        pactl set-default-sink "$output_spec" && notify-send "Audio Output" "Switched to: $selection"
    fi
fi
