#!/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Screenshot'
mesg="DIR: $(xdg-user-dir PICTURES)/Screenshots"

if [[ "$theme" == *'type-1'* ]]; then
  list_col='1'
  list_row='5'
  win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
  list_col='1'
  list_row='5'
  win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
  list_col='1'
  list_row='5'
  win_width='520px'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
  list_col='5'
  list_row='1'
  win_width='670px'
fi

# Options
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1=" Capture Desktop"
  option_2=" Capture Area"
  option_3=" Capture Window"
  option_4=" Capture in 5s"
  option_5=" Capture in 10s"
else
  option_1=""
  option_2=""
  option_3=""
  option_4=""
  option_5=""
fi

# Rofi CMD
rofi_cmd() {
  rofi -theme-str "window {width: $win_width;}" \
    -theme-str "listview {columns: $list_col; lines: $list_row;}" \
    -theme-str 'textbox-prompt-colon {str: "";}' \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Screenshot
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(hyprctl monitors | grep "active" | cut -d ',' -f 2 | tr -d '[:space:]')
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

if [[ ! -d "$dir" ]]; then
  mkdir -p "$dir"
fi

# notify and view screenshot
notify_view() {
  notify_cmd_shot='dunstify -u low --replace=699'
  ${notify_cmd_shot} "Copied to clipboard."
  # imv "${dir}/${file}" & # Run in background.  Change imv if needed.
  if [[ -e "$dir/$file" ]]; then
    ${notify_cmd_shot} "Screenshot Saved."
  else
    ${notify_cmd_shot} "Screenshot Deleted."
  fi
}

# convert to jpg
convert_to_jpg() {
  if [[ -f "${dir}/${file}" ]]; then
    jpg_file="${file%.png}.jpg"
    convert "${dir}/${file}" "${dir}/${jpg_file}" 2>/dev/null ||
      mogrify -format jpg "${dir}/${file}" 2>/dev/null ||
      sips -s format jpeg "${dir}/${file}" --out "${dir}/${jpg_file}" 2>/dev/null

    if [[ -f "${dir}/${jpg_file}" ]]; then
      dunstify -u low --replace=699 "JPG version created."
    else
      dunstify -u low --replace=699 "Failed to create JPG version."
    fi
  fi
}

# Copy screenshot to clipboard
copy_shot() {
  wl-clipboard -t image/png <"$file"
}

# countdown
countdown() {
  for sec in $(seq $1 -1 1); do
    dunstify -t 1000 --replace=699 "Taking shot in : $sec"
    sleep 1
  done
}

# take shots
shotnow() {
  cd "${dir}" && sleep 0.5 && grim "${dir}/${file}" && copy_shot
  notify_view
  convert_to_jpg
}

shot5() {
  countdown '5'
  sleep 1 && cd "${dir}" && grim "${dir}/${file}" && copy_shot
  notify_view
  convert_to_jpg
}

shot10() {
  countdown '10'
  sleep 1 && cd "${dir}" && grim "${dir}/${file}" && copy_shot
  notify_view
  convert_to_jpg
}

shotwin() {
  window_id=$(hyprctl activewindow | grep "window:" | cut -d ':' -f 2 | tr -d ' ')
  cd "${dir}" && grim -w "$window_id" "${dir}/${file}" && copy_shot
  notify_view
  convert_to_jpg
}

shotarea() {
  cd "${dir}" && grim -g "$(slurp)" "${dir}/${file}" && copy_shot
  notify_view
  convert_to_jpg
}

# Execute Command
run_cmd() {
  if [[ "$1" == '--opt1' ]]; then
    shotnow
  elif [[ "$1" == '--opt2' ]]; then
    shotarea
  elif [[ "$1" == '--opt3' ]]; then
    shotwin
  elif [[ "$1" == '--opt4' ]]; then
    shot5
  elif [[ "$1" == '--opt5' ]]; then
    shot10
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$option_1)
  run_cmd --opt1
  ;;
$option_2)
  run_cmd --opt2
  ;;
$option_3)
  run_cmd --opt3
  ;;
$option_4)
  run_cmd --opt4
  ;;
$option_5)
  run_cmd --opt5
  ;;
esac
