#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='style'
th="-theme ${dir}/${theme}.rasi"

divider="---------"
goback="Back"

wifi_on() {
    if nmcli radio wifi | grep -q "enabled"; then
        return 0
    else
        return 1
    fi
}

toggle_wifi() {
    if wifi_on; then
        nmcli radio wifi off
        show_menu
    else
        nmcli radio wifi on
        show_menu
    fi
}

network_connected() {
    con_state=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
    if [[ -n "$con_state" ]]; then
        echo "Connected: $con_state"
        return 0
    else
        echo "Connected: no"
        return 1
    fi
}

disconnect_network() {
    nmcli device disconnect wlan0
    show_menu
}

network_menu() {
    network=$1
    ssid=$(echo "$network" | awk '{print $1}')
    security=$(echo "$network" | awk '{print $2}')

    connection_status=$(network_connected)

    options="$connection_status\nConnect\nDisconnect\n$divider\n$goback\nExit"

    chosen="$(echo -e "$options" | $rofi_command "$ssid" $th)"

    case "$chosen" in
    "" | "$divider")
        echo "No option chosen."
        ;;
    "Connect")
        connect_network "$ssid" "$security"
        ;;
    "Disconnect")
        disconnect_network
        ;;
    "$goback")
        show_menu
        ;;
    esac
}

connect_network() {
    ssid=$1
    security=$2

    knowncon=$(nmcli connection show)

    if echo "$knowncon" | grep -q "^$ssid"; then
        nmcli con up "$ssid" && notify-send "WiFi" "Connected to $ssid"
    else
        if [[ "$security" =~ "WPA" ]] || [[ "$security" =~ "WEP" ]]; then
            password=$(rofi -dmenu -p "Password: " -password -lines 1 -theme ${dir}/${theme}.rasi)
            if [[ -n "$password" ]]; then
                nmcli dev wifi con "$ssid" password "$password" && notify-send "WiFi" "Connected to $ssid"
            fi
        else
            nmcli dev wifi con "$ssid" && notify-send "WiFi" "Connected to $ssid"
        fi
    fi
    show_menu
}

manual_entry() {
    manual_ssid=$(rofi -dmenu -p "SSID: " -lines 1 -theme ${dir}/${theme}.rasi)
    if [[ -n "$manual_ssid" ]]; then
        password=$(rofi -dmenu -p "Password (leave empty if none): " -password -lines 1 -theme ${dir}/${theme}.rasi)
        if [[ -n "$password" ]]; then
            nmcli dev wifi con "$manual_ssid" password "$password" && notify-send "WiFi" "Connected to $manual_ssid"
        else
            nmcli dev wifi con "$manual_ssid" && notify-send "WiFi" "Connected to $manual_ssid"
        fi
    fi
    show_menu
}

show_menu() {
    if wifi_on; then
        power="Power: on"

        rofi -e "Scanning networks..." -theme ${dir}/${theme}.rasi &
        rofi_pid=$!
        
        nmcli dev wifi rescan 2>/dev/null

        networks=$(nmcli -f SSID,SECURITY device wifi list | tail -n +2 | grep -v "^--" | awk '{
            ssid = $1
            security = ""
            for (i=2; i<=NF; i++) security = security $i " "
            if (ssid != "") printf "%s\n", ssid
        }' | sort -u)
        
        kill $rofi_pid 2>/dev/null

        current_ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

        if [[ -n "$networks" ]]; then
            options="$power\nManual\nExit\n$divider\n$networks"
        else
            options="$power\nManual\nExit"
        fi
    else
        power="Power: off"
        options="$power\nExit"
    fi

    chosen="$(echo -e "$options" | $rofi_command "WiFi" $th)"

    case "$chosen" in
    "" | "$divider")
        echo "No option chosen."
        ;;
    "$power")
        toggle_wifi
        ;;
    "Manual")
        manual_entry
        ;;
    "Exit")
        exit 0
        ;;
    *)
        if [[ -n "$chosen" ]] && [[ "$chosen" != "$divider" ]]; then
            network_line=$(nmcli -f SSID,SECURITY device wifi list | grep "^$chosen")
            if [[ -n "$network_line" ]]; then
                network_menu "$network_line"
            fi
        fi
        ;;
    esac
}

rofi_command="rofi -dmenu $* -p "

show_menu
