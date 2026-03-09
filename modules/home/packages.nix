{ pkgs, lib, system, inputs, unstable, hostConfig, ... }:

{
  home.packages = with pkgs; [
    unstable.vicinae

    neovim
    yazi
    ripgrep
    fd
    lazygit
    lazydocker
    btop
    ghostty
    kitty

    go
    nodejs
    python313
    lua
    rustup
    cmake
    gnumake
    gcc
    libgcc
    gdb
    lldb
    lua54Packages.luarocks

    gnome-calculator
    brave
    firefox
    chromium
    inputs.zen-browser.packages."${system}".beta
    unstable.opencode
    unstable.antigravity
    spotify
    discord
    zathura
    evince
    unstable.obsidian
    unstable.zed-editor
    unstable.localsend
    libreoffice

    # GTK file manager
    xfce.thunar
    unstable.nautilus

    # Media viewers
    mpv
    unstable.imv

    # Desktop/Wayland utilities
    waybar
    swww
    rofi
    libqalculate
    dunst
    wl-clipboard
    cliphist
    pulseaudio
    wireplumber

    bibata-cursors
    base16-schemes

    grim
    slurp
    libnotify
    ntfs3g
    xwayland-satellite
    fastfetch

    # nvim dependencies
    imagemagick
    trash-cli
    sqlite
    python313Packages.pynvim

    # SQL database clients
    usql # universal SQL CLI (mssql, postgres, mysql, sqlite, etc.)
    unstable.dblab # interactive TUI database explorer
    freetds # TDS protocol driver for MSSQL connections from Linux
    unixODBC # ODBC driver manager (needed by some SQL tools)
    dbeaver-bin # GUI database tool (SSMS replacement — mssql, postgres, mysql, etc.)
  ]
  # Packages only for bare-metal (not VM)
  ++ lib.optionals (!hostConfig.isVM) [
    hyprlock
    hypridle
    brightnessctl
    obs-studio
  ];
}
