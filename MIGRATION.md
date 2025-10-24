# NixOS Restructure Summary

## What Changed

### New Modular Structure
```
dotfiles/
├── flake.nix                          # ✓ Updated with mkHost helper
├── hosts/dell-pc/
│   ├── default.nix                    # ✓ Minimal host config
│   └── hardware.nix                   # ✓ Moved from hardware-configuration.nix
├── modules/
│   ├── nixos/
│   │   ├── core.nix                   # ✓ Boot, networking, nix settings, core packages
│   │   └── desktop.nix                # ✓ Hyprland, SDDM, Bluetooth, desktop packages
│   └── home-manager/
│       ├── bash.nix                   # ✓ Converted from .bashrc
│       ├── tmux.nix                   # ✓ Converted from .tmux.conf
│       └── tmux-sessionizer.nix       # ✓ Converted from .tmux-sessionizer script
├── home/oussama/
│   ├── default.nix                    # ✓ User packages, git config
│   └── profiles/hyprland/
│       └── default.nix                # ✓ WM-specific configs and symlinks
└── .config/                           # Existing dotfiles (unchanged)
```

### Files Replaced (but preserved)
- `configuration.nix` → `hosts/dell-pc/default.nix` + `modules/nixos/{core,desktop}.nix`
- `home.nix` → `home/oussama/default.nix` + `home/oussama/profiles/hyprland/default.nix`
- `hardware-configuration.nix` → `hosts/dell-pc/hardware.nix`
- `.bashrc` → `modules/home-manager/bash.nix`
- `.tmux.conf` → `modules/home-manager/tmux.nix`
- `.tmux-sessionizer` → `modules/home-manager/tmux-sessionizer.nix`
- `.gitconfig` → `home/oussama/default.nix` (programs.git section)

### New Features Added

#### System-Level (modules/nixos/desktop.nix)
- ✅ SDDM display manager with Wayland support (no auto-login)
- ✅ Bluetooth enabled with powerOnBoot
- ✅ Environment variables: EDITOR=nvim
- ✅ Hyprland session variables (XDG_CURRENT_DESKTOP, etc.)

#### User-Level (modules/home-manager/)
- ✅ Starship prompt (declarative)
- ✅ Zoxide with bash integration
- ✅ FZF with bash integration
- ✅ Tmux with TPM plugins:
  - vim-tmux-navigator
  - tmux-sensible
  - tmux-yank
  - rose-pine theme
- ✅ All bash aliases preserved
- ✅ tmux-sessionizer available as command

### Package Organization

#### System Packages (modules/nixos/)
**Core (core.nix):**
- vim, wget, git, unzip, unrar, zip

**Desktop (desktop.nix):**
- kitty, ghostty, waybar, hyprpaper
- rofi-wayland, rofi-calc, dunst
- wl-clipboard, cliphist
- neovim, btop
- bibata-cursors
- Fonts: nerd-fonts.jetbrains-mono, icomoon-feather

#### User Packages (home/oussama/)
**Development:**
- nodejs, go, rustup, python311, lua
- cmake, gnumake, gcc, gdb, lldb
- lua54Packages.luarocks

**CLI Tools:**
- yazi, ripgrep, fd, lazygit, fzf, zoxide

**GUI Applications:**
- zen-browser (beta from flake)
- opencode (unstable)

### Preserved Features
✓ All tmux keybindings and settings
✓ All bash aliases (v, y, ta, lg, op, data, udata)
✓ Starship prompt
✓ Zoxide integration
✓ FZF integration
✓ Git safe directories
✓ Hyprland auto-start on tty1
✓ Symlinked configs (hypr, nvim, waybar, rofi, ghostty, yazi, lazygit)
✓ Pipewire audio
✓ Hyprland with XWayland

## How to Use

### Build and Switch
```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#dell-pc
```

### Add New Host
1. Create `hosts/new-hostname/` with `default.nix` and `hardware.nix`
2. Add to `flake.nix`:
```nix
nixosConfigurations = {
  dell-pc = mkHost "dell-pc" "oussama";
  new-hostname = mkHost "new-hostname" "username";
};
```

### Add New User
1. Create `home/username/default.nix`
2. Create `home/username/profiles/hyprland/default.nix` (or other WM)
3. Update host config to add the user account

### Switch Window Manager
Edit `home/oussama/default.nix`:
```nix
imports = [
  ./profiles/sway  # Instead of ./profiles/hyprland
];
```

## Migration Notes
- Old config files are preserved but no longer active
- On first rebuild, home-manager will create `.backup` files
- SDDM login screen will appear (no auto-login like before)
- All functionality should work identically
