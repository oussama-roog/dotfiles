#!/usr/bin/env bash

#!/bin/bash

dir="$HOME/.config/rofi/launcher/"
theme='style-4'

# Run rofi with calculator input and copy result to clipboard on Ctrl+Enter
rofi -show calc -modi calc -no-show-match -no-show-input -theme "${dir}/${theme}.rasi" -calc-command "echo -n '{result}' | wl-copy"
