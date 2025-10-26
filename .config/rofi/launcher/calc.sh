#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='style'

expression=$(rofi -dmenu -p "Calc =" -theme-str 'listview {enabled: false;}' -theme ${dir}/${theme}.rasi)

if [[ -n "$expression" ]]; then
    result=$(qalc -t "$expression" 2>/dev/null)

    if [[ -n "$result" ]]; then
        echo -n "$result" | wl-copy
        notify-send "Calculator" "Result: $result\nCopied to clipboard"
    else
        notify-send "Calculator" "Invalid expression"
    fi
fi
