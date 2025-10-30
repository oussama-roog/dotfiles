#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/horizontal"
theme='style'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
shutdown=''
reboot=''
lock=''
suspend='󰤄'
logout=''
yes=''
no='󰅚'

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "$host" \
        -theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: north; anchor: north; fullscreen: false; width: 350px; y-offset: 5px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff
        elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
        elif [[ $1 == '--suspend' ]]; then
            systemctl suspend
        elif [[ $1 == '--logout' ]]; then
            loginctl terminate-session $XDG_SESSION_ID
        fi
    else
        exit 0
    fi
}

# Lock screen function
lock_screen() {
    if command -v hyprlock &>/dev/null; then
        hyprlock
    else
        echo "hyprlock not found"
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
    run_cmd --shutdown
    ;;
$reboot)
    run_cmd --reboot
    ;;
$lock)
    lock_screen
    ;;
$suspend)
    run_cmd --suspend
    ;;
$logout)
    run_cmd --logout
    ;;
esac
