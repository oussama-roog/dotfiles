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
    python311
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
    # obsidian

    bibata-cursors
    
    grim
    slurp
    libnotify
    ntfs3g
  ];
}
