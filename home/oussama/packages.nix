{ pkgs, system, inputs, unstable, ... }:

{
  home.packages = with pkgs; [
    neovim
    yazi
    ripgrep
    fd
    lazygit
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

    unstable.opencode
    inputs.zen-browser.packages."${system}".beta
    spotify
    discord
    obs-studio
    zathura
    unstable.obsidian
    unstable.zed-editor

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

    # nvim dependencies
    imagemagick
    trash-cli
    sqlite
    python313Packages.pynvim
  ];
}
