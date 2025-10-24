{ pkgs, system, inputs, unstable, ... }:

{
  home.packages = with pkgs; [
    neovim
    yazi
    ripgrep
    fd
    lazygit
    btop
    
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
    ghostty
    kitty

    bibata-cursors
  ];
}
