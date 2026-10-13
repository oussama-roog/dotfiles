# Taskwarrior 3, the store behind the quickshell tasks centre (Mod+T).
#
# Config only: the tasks themselves live in $XDG_DATA_HOME/task (one SQLite
# file per machine), outside the repo and the Nix store, so each host keeps
# its own list and rebuilds never touch it.
{ config, pkgs, ... }:

{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      confirmation = false;
      recurrence.confirmation = false;
      # Silences the "Recently upgraded, run task news" line.
      news.version = config.programs.taskwarrior.package.version;
    };
  };
}
