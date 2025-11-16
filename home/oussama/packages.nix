{ pkgs, system, inputs, unstable, ... }:

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
    inputs.zen-browser.packages."${system}".beta
    unstable.opencode
    spotify
    discord
    obs-studio
    zathura
    evince
    unstable.obsidian
    unstable.zed-editor
    unstable.localsend

    # GTK file manager
    xfce.thunar
    unstable.nautilus

    # Media viewers
    mpv
    unstable.imv

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
  ];
}
