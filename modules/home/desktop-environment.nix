{ pkgs, lib, config, hostConfig, ... }:

{
  # Cursor theme (works for both X11/i3 and Wayland/niri)
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    size = 24;
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };
  # Hyprlock systemd service (bare-metal only — no screen locking in VM)
  systemd.user.services = lib.mkIf (!hostConfig.isVM) {
    hyprlock = {
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

    hypridle = {
      Unit = {
        Description = "Hyprland idle daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Type = "simple";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # Lock session target (bare-metal only)
  systemd.user.targets = lib.mkIf (!hostConfig.isVM) {
    lock-session = {
      Unit = {
        Description = "Lock the current session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "hyprlock.service" ];
        Before = [ "sleep.target" ];
      };
    };
  };

  # Symlink config files from dotfiles
  xdg.configFile =
    let
      dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
      create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
      configs = {
        hypr = "hypr";
        niri = "niri";
        i3 = "i3";
        polybar = "polybar";
        nvim = "nvim";
        waybar = "waybar";
        rofi = "rofi";
        ghostty = "ghostty";
        kitty = "kitty";
        yazi = "yazi";
        lazygit = "lazygit";
        dunst = "dunst";
        zed = "zed";
      };
    in
    builtins.mapAttrs
      (name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs;
}
