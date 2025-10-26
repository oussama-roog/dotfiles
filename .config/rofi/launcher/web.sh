#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='style'

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

# Generate the selection menu
selection=$(printf "%s\n" "${web_order[@]}" | rofi -dmenu -i -theme ${dir}/${theme}.rasi -p "WebSites")

if [[ -n "$selection" ]]; then
    url="${urls[$selection]}"
    firefox "$url"
fi
