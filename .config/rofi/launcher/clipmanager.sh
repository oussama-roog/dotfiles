#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='style'

cliphist list | rofi -dmenu -display-columns 2 -p "Clipboard:" -theme "${dir}/${theme}.rasi" | cliphist decode | wl-copy
