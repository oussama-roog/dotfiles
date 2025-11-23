#!/usr/bin/env bash

web_data=(
    "Perplexity" "https://www.perplexity.ai/"
    "Gemini" "https://gemini.google.com/app"
    "Claude" "https://claude.ai/new"
    "ChatGPT" "https://chatgpt.com/?temporary-chat=true"
    "DeepSeek" "https://chat.deepseek.com/"
    "Youtube" "https://youtube.com/"
    "X" "https://x.com/"
    "Reddit" "https://reddit.com/"
    "keep" "https://keep.google.com/"
    "Gmail" "https://mail.google.com/"
)

# Build arrays from the data
declare -A urls
web_order=()

for ((i = 0; i < ${#web_data[@]}; i += 2)); do
    name="${web_data[i]}"
    url="${web_data[i + 1]}"
    urls["$name"]="$url"
    web_order+=("$name")
done

# Generate the selection menu with vicinae dmenu
selection=$(printf "%s\n" "${web_order[@]}" | vicinae dmenu --placeholder "Select Website")

if [[ -n "$selection" ]]; then
    url="${urls[$selection]}"

    # Extract domain from URL for matching
    domain=$(echo "$url" | sed -E 's|https?://||; s|/.*||')

    # Check if a window with this domain is already open
    window_id=$(niri msg -j windows | jq -r --arg domain "$domain" '.[] | select(.app_id | contains($domain)) | .id' | head -n1)

    if [[ -n "$window_id" ]]; then
        # Window exists, focus it
        niri msg action focus-window --id "$window_id"
    else
        # Window doesn't exist, open new one
        chromium --app="$url"
    fi
fi
