{ pkgs, config, ... }:

{
  # Hyprlock systemd service configuration
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

  # Symlink config files from dotfiles
  xdg.configFile =
    let
      dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
      create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
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
      };
    in
    builtins.mapAttrs
      (name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs;
}
