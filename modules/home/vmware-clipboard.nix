{ pkgs, ... }:

# VMware host <-> niri clipboard.
#
# vmware-user (vmtoolsd -n vmusr) only speaks X11 and talks to the host
# clipboard through Xwayland. xwayland-satellite only syncs the clipboard while
# an X11 window has focus, and vmware-user never has focus, so we bridge the
# Wayland and X11 clipboards ourselves.
let
  bridge = pkgs.writeShellApplication {
    name = "vmware-clipboard-bridge";
    runtimeInputs = with pkgs; [ wl-clipboard xclip clipnotify coreutils ];
    text = ''
      # Called by wl-paste --watch with the new Wayland clipboard on stdin
      if [ "''${1:-}" = "to-x" ]; then
        new=$(cat)
        [ -n "$new" ] || exit 0
        cur=$(timeout 1 xclip -o -selection clipboard 2>/dev/null || true)
        if [ "$new" != "$cur" ]; then
          printf '%s' "$new" | xclip -selection clipboard -i >/dev/null 2>&1
        fi
        exit 0
      fi

      # Wayland -> X11 (host)
      wl-paste --type text --watch "$0" to-x &

      # X11 (host) -> Wayland
      while clipnotify; do
        cur=$(timeout 1 xclip -o -selection clipboard 2>/dev/null) || continue
        [ -n "$cur" ] || continue
        wl=$(timeout 1 wl-paste -n --type text 2>/dev/null || true)
        if [ "$cur" != "$wl" ]; then
          printf '%s' "$cur" | wl-copy
        fi
      done

      # clipnotify failed (X went away): exit so systemd restarts us
      exit 1
    '';
  };
in
{
  systemd.user.services.vmware-clipboard-bridge = {
    Unit = {
      Description = "Sync niri (Wayland) clipboard with X11 for VMware";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
    };
    Service = {
      Environment = [ "DISPLAY=:0" ];
      ExecStart = "${bridge}/bin/vmware-clipboard-bridge";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "niri.service" ];
  };

  # vmware-user is started by its XDG autostart entry with Restart=no, so a
  # crash (VM suspend/resume, host reconnect) kills the clipboard until reboot.
  xdg.configFile."systemd/user/app-vmware\\x2duser@autostart.service.d/restart.conf".text = ''
    [Service]
    Restart=always
    RestartSec=2
  '';
}
