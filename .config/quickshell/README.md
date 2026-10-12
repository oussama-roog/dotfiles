# Quickshell Niri Configuration

This Quickshell configuration is to work natively with the Niri compositor instead of Hyprland. It features a morphing, two-window architecture ("Pill Shell") that stays out of your way and expands dynamically when you need it.

## Keybindings (via `niri msg`)

| Shortcut | Action |
|----------|--------|
| `Mod+Space` | Toggle App Launcher |
| `Mod+W` | Toggle Web Launcher |
| `Mod+P` | Toggle Power Menu |
| `Mod+V` | Toggle Clipboard History |
| `Mod+N` | Toggle Notification Inbox |
| `Mod+Shift+W` | Toggle Wallpaper Picker |

*Note: All IPC calls use the format `qs ipc call pill <surface>`.*

## The Pill

The resting pill is a single bar: workspace dots on the left (click to switch),
CPU % and used RAM (GB) in the middle, the clock on the right. There is no hover
expansion; surfaces open only through the shortcuts above.

### Available Surfaces
* **Launcher:** Fuzzy app search.
* **Web Launcher:** Type to search predefined websites. Use `Up`/`Down` to navigate, `Enter` to launch (focuses existing Niri window or opens in a Chromium `--app`).
* **Clipboard:** Click to copy an item to the clipboard.
* **Power:** Click to Lock, Logout or Suspend; press-and-hold to Reboot or Shutdown.
* **Wallpaper:** Scroll to view wallpapers. Click to apply immediately using `awww`.
* **Inbox:** Grouped notifications. Hover over a notification and click the `x` to dismiss.

### OSD & Toasts
* **Volume/Brightness Changes:** Trigger a fast On-Screen Display (OSD) pill showing the new percentage.
* **Notifications:** Show as stacked pop-up toasts below the main pill area.

## Theming
Colors follow the theme switcher: `scripts/themes/quickshell.sh` writes the base16 palette to `colors.json` in this folder, and `Singletons/Dyn.qml` watches it so the shell recolours live. UI tokens are defined in `Singletons/Theme.qml`. Settings are stored in `flags.json` here as well.
