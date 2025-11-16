{ config, pkgs, system, inputs, unstable, ... }:

let
  configs = {
    hypr = "hypr";
    niri = "niri";
    nvim = "nvim";
    waybar = "waybar";
    rofi = "rofi";
    ghostty = "ghostty";
    yazi = "yazi";
    lazygit = "lazygit";
    dunst = "dunst";
    zed = "zed";
    "gtk-3.0" = "gtk-3.0";
    "gtk-4.0" = "gtk-4.0";
  };
in
{
  imports = [
    ./bash.nix
    ./tmux.nix
    ./packages.nix
    ./dev-tools.nix
  ];

  home.username = "oussama";
  home.homeDirectory = "/home/oussama";
  home.stateVersion = "25.05";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  services.playerctld.enable = true;

  # Configure hyprlock as the default screen locker
  systemd.user.services.hyprlock = {
    Unit = {
      Description = "Hyprlock screen locker";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
      Type = "simple";
      Restart = "no";
    };
  };

  # Trigger hyprlock when lock-session.target is activated
  systemd.user.targets.lock-session = {
    Unit = {
      Description = "Lock the current session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "hyprlock.service" ];
      Before = [ "sleep.target" ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Video applications
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/*" = "mpv.desktop";

      # Image applications
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/*" = "imv.desktop";

      # Browser/web applications (add these)
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/chrome" = "zen-beta.desktop";
      "application/x-extension-htm" = "zen-beta.desktop";
      "application/x-extension-html" = "zen-beta.desktop";
      "application/x-extension-shtml" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
      "application/x-extension-xhtml" = "zen-beta.desktop";
      "application/x-extension-xht" = "zen-beta.desktop";

      # PDF viewer
      "application/pdf" = "org.pwmt.zathura.desktop";

      # Terminal
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      "application/x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
    };
  };

  programs.git = {
    enable = true;
    userEmail = "oussamaroog@gmail.com";
    userName = "oussama-roog";
    extraConfig = {
      init.defaultBranch = "main";
      # safe = { directory = []; };
    };
  };

  xdg.configFile =
    let
      dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
      create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    in
    builtins.mapAttrs
      (name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs;
}
