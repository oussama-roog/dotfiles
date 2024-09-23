#!/bin/bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch Polybar, using default config location ~/.config/polybar/config.ini

# polybar -c ~/.config/polybar/mytheme/config.ini first 2>&1 | tee -a /tmp/polbar.log & disown
# polybar -c ~/.config/polybar/mytheme/config.ini second 2>&1 | tee -a /tmp/polbar.log & disown
# polybar -c ~/.config/polybar/mytheme/config.ini third 2>&1 | tee -a /tmp/polbar.log & disown
# polybar -c ~/.config/polybar/mytheme/config.ini fourth 2>&1 | tee -a /tmp/polbar.log & disown
#polybar -c ~/.config/polybar/mytheme/config.ini first 2>&1 | tee -a /tmp/polybar.log & disown
#polybar -c ~/.config/polybar/mytheme/config.ini center 2>&1 | tee -a /tmp/polybar.log & disown
#polybar -c ~/.config/polybar/mytheme/config.ini right 2>&1 | tee -a /tmp/polybar.log & disown
#~/.config/polybar/scripts/nowPlayingLauncher.sh & disown

# if type "xrandr"; then
#   for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     MONITOR=$m polybar -c ~/.config/polybar/mytheme/config.ini left 2>&1 | tee -a /tmp/polbar.log & disown
#     MONITOR=$m polybar -c ~/.config/polybar/mytheme/config.ini center 2>&1 | tee -a /tmp/polbar.log & disown
#     MONITOR=$m polybar -c ~/.config/polybar/mytheme/config.ini right 2>&1 | tee -a /tmp/polbar.log & disown
#   done
# else
#   polybar -c ~/.config/polybar/mytheme/config.ini left 2>&1 | tee -a /tmp/polbar.log & disown
#   polybar -c ~/.config/polybar/mytheme/config.ini center 2>&1 | tee -a /tmp/polbar.log & disown
#   polybar -c ~/.config/polybar/mytheme/config.ini right 2>&1 | tee -a /tmp/polbar.log & disown
# fi

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -c ~/.config/polybar/mytheme/config.ini main 2>&1 | tee -a /tmp/polbar.log & disown
  done
else
  polybar -c ~/.config/polybar/mytheme/config.ini main 2>&1 | tee -a /tmp/polbar.log & disown
fi
echo "Polybar launched..."
