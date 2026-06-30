# Quickshell Niri Configuration

This Quickshell configuration is based on the Ricelin template, fully adapted to work natively with the Niri compositor instead of Hyprland. It features a morphing, two-window architecture ("Pill Shell") that stays out of your way and expands dynamically when you need it.

## Keybindings (via `niri msg`)

| Shortcut | Action |
|----------|--------|
| `Mod+Space` or `Mod+W` | Toggle Web Launcher (app & web search) |
| `Mod+P` | Toggle Power Menu |
| `Mod+V` | Toggle Clipboard History |
| `Mod+N` | Toggle Notification Center & Networks (Link Surface) |
| `Mod+Shift+W` | Toggle Wallpaper Picker |

*Note: All IPC calls use the format `qs ipc call pill <surface>`.*

## Mouse Interactions

### The Pill (Rest / Hover)
* **Hover:** Expands the rest pill to show the full bar (Clock, WiFi, Battery, Inbox, Mixer, Power, Sysmon).
* **Clicking Icons:** Clicking any icon in the expanded hover bar will open its respective morphing surface.
* **Workspace Dots:** The active workspace is represented by a wider vermillion line. You can click on the workspace dots to switch to that workspace.

### Available Surfaces
* **Web Launcher:** Type to search predefined websites. Use `Up`/`Down` to navigate, `Enter` to launch (focuses existing Niri window or opens in a Chromium `--app`).
* **Mixer:** Use the mouse wheel to scroll through volume levels. Click the mute icon to toggle mute.
* **Calendar:** Browse months, view current time.
* **Clipboard:** Click to copy an item to the clipboard.
* **Power:** Click to Lock, Suspend, Reboot, or Shutdown.
* **Media:** Controls MPRIS players. Play/Pause, Next/Prev.
* **Wallpaper:** Scroll to view wallpapers. Click to apply immediately using `awww`.
* **Link (Connectivity & Inbox):** View WiFi and Bluetooth status. Below is the Notification Inbox where you can view grouped notifications. Hover over a notification and click the `x` to dismiss.
* **Sysmon:** Displays live dials for CPU, RAM, Network, and Disk usage, along with system uptime.
* **Settings:** Access other settings surfaces.

### OSD & Toasts
* **Volume/Brightness Changes:** Trigger a fast On-Screen Display (OSD) pill showing the new percentage.
* **Notifications:** Show as stacked pop-up toasts below the main pill area.

## Theming
This configuration uses the static "Washi" color palette from the Ricelin template. It does not pull colors from external themes. Colors and UI tokens are defined in `Singletons/Theme.qml`.
