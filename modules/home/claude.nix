{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  bridge = "${dotfiles}/scripts/claude-qs";

  # Keys this module owns in ~/.claude/settings.json. The file itself stays
  # writable so Claude Code can still save /config changes and permissions.
  hookEvents = [
    "SessionStart" "UserPromptSubmit" "PreToolUse" "PostToolUse"
    "PostToolUseFailure" "PermissionRequest" "Notification" "Stop" "SessionEnd"
  ];
  managed = {
    hooks = lib.genAttrs hookEvents (_: [
      { hooks = [ { type = "command"; command = "${bridge} hook"; } ]; }
    ]);
    statusLine = { type = "command"; command = "${bridge} statusline"; padding = 0; };
    # Commits and PRs carry only the configured git user, no Claude trailer.
    includeCoAuthoredBy = false;
    attribution = { commit = ""; pr = ""; };
  };
  managedJson = pkgs.writeText "claude-managed-settings.json" (builtins.toJSON managed);

  # Every directory in claude/skills becomes ~/.claude/skills/<name>.
  skillsDir = ../../claude/skills;
  skills = lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir);
in
{
  home.file = {
    ".claude/CLAUDE.md".source = ../../claude/CLAUDE.md;
  } // lib.mapAttrs' (name: _:
    lib.nameValuePair ".claude/skills/${name}" { source = skillsDir + "/${name}"; }
  ) skills;

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    [ -s "$settings" ] || echo '{}' > "$settings"
    tmp="$(mktemp)"
    if ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings" ${managedJson} > "$tmp"; then
      run mv "$tmp" "$settings"
    else
      rm -f "$tmp"
      echo "claude: $settings is not valid JSON, left untouched" >&2
    fi
  '';
}
