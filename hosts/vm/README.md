# VM — NixOS VMware Setup Guide

NixOS running as a VMware VM on Windows. The VM uses the external monitor (niri WM), Windows uses the laptop monitor.

---

## 1. VMware Workstation Setup

### Install VMware Workstation Pro

Download from [VMware](https://www.vmware.com/products/workstation-pro.html) (free for personal use). Install with default options.

### Create the VM

1. **File → New Virtual Machine → Custom**
2. Hardware compatibility: latest
3. **Installer disc image**: Use [NixOS minimal ISO](https://nixos.org/download/#nixos-iso) (x86_64)
4. Guest OS: **Linux → Other Linux 6.x kernel 64-bit**
5. VM name: `NixOS`
6. Processors: **8+ cores** (you have plenty with 32GB RAM)
7. Memory: **16384 MB** (16GB — leaves 16GB for Windows)
8. Network: **NAT** (shares your Windows IP — Fortinet sees one device)
9. Disk: **100GB+**, store as single file
10. Finish

### VM Settings (Important)

Go to **VM → Settings**:

| Setting | Value |
|---------|-------|
| **Display** | Uncheck "Accelerate 3D graphics", set monitor to your main monitor resolution |
| **Options → Shared Folders** | Always enabled. Add folder named `share` → point to your Windows share folder/partition (e.g., `D:\` or `D:\Share`) |
| **Options → VMware Tools** | Automatically update |
| **Options → Keyboard** | Enhanced keyboard: **Required** (this makes Win key work properly in VM) |

> **Enhanced keyboard driver** is critical — it properly captures the Win (Super/Mod) key for niri keybinds when the VM is focused, and releases it to Windows when you click outside.

### Monitor Setup

To use the VM fullscreen on the external monitor:

1. Move the VMware window to your **external monitor**
2. **View → Full Screen** (or `Ctrl+Alt+Enter`)
3. The VM takes over the external monitor, laptop stays on Windows
4. To exit fullscreen: move mouse to top edge → click the minimize/fullscreen bar

---

## 2. Windows: Create Shared Partition

### Create a new NTFS partition

1. Open **Disk Management** (Win+X → Disk Management)
2. Shrink an existing partition to free space (e.g., 100-200GB)
3. Right-click the unallocated space → **New Simple Volume**
4. Format as **NTFS**, assign drive letter (e.g., `D:`)
5. Label it `Share`

### Add to VMware shared folders

1. VM → Settings → Options → Shared Folders
2. Add → Name: `share`, Host path: `D:\` (or `D:\Share`)
3. Enable **Always enabled**

This mounts automatically in the VM at `~/share`.

---

## 3. NixOS Installation (Step by Step)

### Boot the ISO

Power on the VM. It boots into the NixOS minimal installer (a terminal).

### Connect to the internet

The VM uses NAT networking, so internet should work automatically:

```bash
# Verify internet works
ping -c 3 google.com
```

### Become root

```bash
sudo -i
```

### Partition the virtual disk

The VM has a single virtual disk (`/dev/sda`). We create two partitions: a small EFI boot partition and the rest for the root filesystem.

```bash
# Create GPT partition table
parted /dev/sda -- mklabel gpt

# Create EFI system partition (512MB)
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 1 esp on

# Create root partition (rest of disk)
parted /dev/sda -- mkpart primary 512MB 100%
```

### Format the partitions

```bash
# Format EFI partition as FAT32 with label "boot"
mkfs.fat -F 32 -n boot /dev/sda1

# Format root partition as ext4 with label "nixos"
mkfs.ext4 -L nixos /dev/sda2
```

### Mount the partitions

```bash
# Mount root
mount /dev/disk/by-label/nixos /mnt

# Create and mount boot
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### Generate hardware configuration

This detects your VM hardware and creates the proper `hardware-configuration.nix`:

```bash
nixos-generate-config --root /mnt
```

### Clone dotfiles and prepare

```bash
# Get git in a temporary shell
nix-shell -p git

# Clone your dotfiles repository
git clone https://github.com/oussama-roog/dotfiles.git /mnt/home/oussama/dotfiles
```

### Copy the generated hardware config

This is critical — replace the template with your actual hardware detection:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/oussama/dotfiles/hosts/vm/hardware-configuration.nix
```

### Install NixOS

```bash
nixos-install --flake /mnt/home/oussama/dotfiles#vm
```

You will be prompted to set the root password. Set it.

### Set your user password

```bash
# After install completes, set user password
nixos-enter --root /mnt -c 'passwd oussama'
```

### Reboot

```bash
reboot
```

Remove the ISO from the VM's virtual CD drive after shutdown (VM → Settings → CD/DVD → Disconnect).

---

## 4. First Boot Setup

After reboot, you auto-login to TTY1 and niri starts automatically.

```bash
# Open a terminal (Mod+Return in niri)

# Create project and note directories
mkdir -p ~/projects
mkdir -p ~/share/notes

# Verify shared folder is mounted
ls ~/share

# If shared folder is not mounted yet:
sudo mount -a

# Fix dotfiles ownership (was cloned as root during install)
sudo chown -R oussama:users ~/dotfiles

# Rebuild to make sure everything is applied
nxs
```

---

## 5. Folder Structure

```
~/
├── dotfiles/           # This repo
├── projects/           # Dev projects (local, fast I/O)
├── share/              # VMware shared folder (Windows ↔ NixOS)
│   └── notes/          # Notes (accessible from both OS)
├── Downloads/
└── .config/            # Symlinked by home-manager
```

- **Projects** live in `~/projects` for fast disk I/O (virtual disk)
- **Notes** live in `~/share/notes` so you can access them from Windows too
- **File sharing**: Drop files in `~/share` to access them from Windows (e.g., send via Outlook)

### tmux-sessionizer (`Ctrl+a, f`)

Opens fzf with: home, Downloads, .config, dotfiles, projects, notes, share

### Yazi shortcuts

| Key | Directory |
|-----|-----------|
| `g /` | Root `/` |
| `g s` | `~/share/` |
| `g p` | `~/projects/` |
| `g n` | `~/share/notes/` |
| `g e` | `~/Documents/` |

---

## 6. Network

**NAT mode**: The VM shares the host Windows IP. All traffic goes through Windows → your company's Fortinet sees only one device with your assigned IP. No extra configuration needed.

- VM can access the internet through your Windows connection
- No separate IP, no MAC conflict
- `curl`, `git`, `npm` etc. all work normally

---

## 7. Audio

VMware passes audio through to Windows automatically. PipeWire in the VM handles the virtual sound card. Volume controls in niri/waybar work normally.

---

## 8. Keyboard (Win/Mod key)

With VMware's **enhanced keyboard driver**:

- **VM has focus** → Win key goes to niri (Mod+1 switches workspace, Mod+Return opens terminal, etc.)
- **Click on Windows** → Win key goes to Windows (Start menu, Win+E explorer, etc.)
- **Ctrl+Alt** → Release keyboard grab (if needed)

All your niri keybinds work exactly as on your laptop. No conflicts.

---

## 9. NixOS Management

```bash
nxs          # Rebuild (sudo nixos-rebuild switch --flake ~/dotfiles#vm)
nxu          # Update flake
nxg          # Garbage collect
nxo          # Optimize store
```

---

## 10. Troubleshooting

### Shared folder not mounting

```bash
# Check if vmhgfs-fuse is available
which vmhgfs-fuse

# Manual mount
sudo mount -t fuse.vmhgfs-fuse .host:/share /home/oussama/share -o umask=022,uid=1000,gid=100,allow_other

# Check VMware shared folder settings
# VM → Settings → Options → Shared Folders must be "Always enabled"
```

### No display / black screen after boot

```bash
# Switch to TTY2: Ctrl+Alt+F2
# Login and start niri manually
niri-session

# Or check logs
journalctl --user -u niri -b
```

### Resolution not fitting monitor

```bash
# VMware tools should auto-resize. If not:
# VM → Settings → Display → Specify monitor resolution
# Or in the VM:
xrandr --output Virtual-1 --mode 1920x1080
```

### Audio not working

```bash
# Check PipeWire
systemctl --user status pipewire
wpctl status

# If no sound device, ensure VMware has sound card enabled:
# VM → Settings → Hardware → Sound Card → Present at power on ✓
```
