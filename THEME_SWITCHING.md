# Dynamic Theme Switching System

This system allows you to switch themes across all your applications in real-time using base16 color schemes.

## Features

- Real-time theme switching without rebuilding NixOS
- Supports all base16-schemes available in nixpkgs
- Theme persistence across reboots
- Updates all applications:
  - Hyprland & Hyprlock
  - Waybar
  - Kitty & Ghostty
  - Rofi
  - Dunst
  - Yazi
  - Neovim
  - Tmux
  - GTK 3 & 4 applications

## Usage

### GUI (Rofi Launcher)

Press `Super + T` to open the theme selector rofi menu.

### Command Line

```bash
# List all available themes
~/dotfiles/scripts/theme-switcher.sh list

# Apply a theme
~/dotfiles/scripts/theme-switcher.sh apply catppuccin-latte

# Show current theme
~/dotfiles/scripts/theme-switcher.sh current
```

## How It Works

1. **Theme Storage**: Base16 themes are installed via nixpkgs and stored in `/nix/store`
2. **Dynamic Lookup**: The script finds the theme directory dynamically, so it works even after nix store hash changes
3. **YAML Parsing**: Themes are parsed from YAML files, handling both commented and uncommented color values
4. **Config Generation**: Color configs are generated for each application in their respective formats:
   - Hyprland: `RRGGBBAA` format (hex + alpha)
   - GTK/CSS: `#RRGGBB` format
   - Nix: `"#RRGGBB"` format
   - TOML/Conf: Various formats per application
5. **Auto-reload**: Applications are reloaded automatically when possible:
   - Waybar: SIGUSR2 signal
   - Ghostty: SIGUSR2 signal
   - Hyprland: `hyprctl reload`
   - Dunst: Restart
   - Tmux: Source config
   - Neovim: Change on next launch

## Theme Persistence

The current theme is saved to `~/.cache/theme-switcher/current-theme` and automatically restored on login via Hyprland's `exec-once` directive.

## Files Modified

When you switch themes, these files are automatically updated:
- `.config/hypr/colors.conf`
- `.config/waybar/colors.css`
- `.config/rofi/colors.rasi`
- `.config/kitty/colors.conf`
- `.config/ghostty/config`
- `.config/dunst/dunstrc`
- `.config/yazi/theme.toml`
- `.config/nvim/lua/oussama/plugins/colorscheme.lua`
- `.config/gtk-3.0/gtk.css`
- `.config/gtk-4.0/gtk.css`
- `home/oussama/colors.nix`

## Popular Themes

- `catppuccin-latte` - Light, pastel theme
- `catppuccin-mocha` - Dark, pastel theme
- `gruvbox-dark-hard` - Dark, retro theme
- `nord` - Arctic, bluish theme
- `dracula` - Dark purple theme
- `tokyo-night-dark` - Dark blue theme
- `black-metal-bathory` - True black theme (default)

## Troubleshooting

**Theme not applying to running apps?**
- Some apps may need to be restarted manually
- Neovim requires reopening to see the new theme

**Rofi menu not showing themes?**
- Ensure base16-schemes is installed in your NixOS configuration
- Run the list command to verify themes are accessible

**Colors look wrong in Hyprland?**
- The script adds `ff` (full opacity) to colors for Hyprland/Hyprlock compatibility
