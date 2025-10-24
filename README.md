# NixOS Configuration

Modular NixOS configuration with multi-host and multi-user support.

## Structure

```
.
├── flake.nix                  # Flake entry point
├── hosts/                     # Host-specific configurations
│   └── dell-pc/
│       ├── configuration.nix # Host configuration
│       └── hardware-configuration.nix # Hardware configuration
├── modules/                   # Reusable modules
│   ├── nixos/
│   │   ├── core.nix          # Core system configuration
│   │   └── desktop.nix       # Desktop environment (Hyprland, SDDM, etc.)
│   └── home-manager/
│       ├── bash.nix          # Bash configuration with starship, zoxide, fzf
│       ├── tmux.nix          # Tmux configuration with plugins
│       └── tmux-sessionizer.nix  # Tmux session manager script
├── home/                      # User configurations
│   └── oussama/
│       ├── home.nix          # User-specific packages and settings
│       └── profiles/
│           └── hyprland/     # Hyprland profile with symlinked configs
│               └── default.nix
└── .config/                   # Dotfiles (symlinked to home-manager)
```

## Features

- **Multi-host support**: Easily add new hosts with `mkHost` helper
- **Multi-user support**: Separate user configurations in `home/`
- **Window manager profiles**: Switch between different WM configs
- **Declarative dotfiles**: Bash, tmux, git managed by home-manager
- **Mixed package sources**: Stable, unstable, and flake inputs (zen-browser)
- **SDDM display manager** with no auto-login
- **Bluetooth support** enabled by default
- **Hyprland** with XWayland support

## Quick Start

### Rebuild System

```bash
sudo nixos-rebuild switch --flake .#dell-pc
```

### Add a New Host

1. Create host directory: `hosts/new-hostname/`
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Add to `flake.nix`:
```nix
nixosConfigurations = {
  dell-pc = mkHost "dell-pc" "oussama";
  new-hostname = mkHost "new-hostname" "username";
};
```

### Add a New User

1. Create user directory: `home/username/`
2. Create `home.nix` with user configuration
3. Create profile: `home/username/profiles/hyprland/` (or other WM)
4. Add user to host configuration in `hosts/hostname/configuration.nix`:
```nix
users.users.username = {
  isNormalUser = true;
  description = "User Name";
  extraGroups = [ "networkmanager" "wheel" ];
};
```

### Switch Window Manager Profile

Edit `home/username/home.nix` imports:
```nix
imports = [
  ./profiles/sway  # Instead of ./profiles/hyprland
];
```

## Aliases

Configured in `modules/home-manager/bash.nix`:

- `v` → nvim
- `y` → yazi
- `ta` → tmux attach/new session
- `lg` → lazygit
- `op` → tmux-sessionizer
- `data` → mount /mnt/data partition
- `udata` → unmount /mnt/data partition

## Packages

### System Packages (modules/nixos/)
- Core: vim, wget, git, compression tools
- Desktop: kitty, ghostty, waybar, rofi, dunst, neovim

### User Packages (home/oussama/)
- Development: nodejs, go, rust, python, lua, gcc, cmake
- CLI Tools: yazi, ripgrep, fd, lazygit, fzf, zoxide
- GUI Apps: zen-browser (beta), opencode

## Notes

- Old dotfiles (`.tmux.conf`, `.bashrc`, `.tmux-sessionizer`) are preserved but no longer used
- Old `configuration.nix` and `home.nix` are replaced by the modular structure
- Symlinked configs in `.config/` remain unchanged and are linked via home-manager
- SDDM is configured without auto-login for security
- Bluetooth starts automatically on boot
