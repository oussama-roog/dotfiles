{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  bridge = "${dotfiles}/scripts/agy-qs";

  # agy's hooks for the quickshell agents dot, as one named group in
  # ~/.gemini/config/hooks.json (shared by the CLI and the IDE); other groups
  # in the file are left alone. Tool events take matcher groups, the others
  # take handlers directly; timeouts are in seconds. The bridge prints
  # nothing, so agy's own permission rules stay in charge.
  handler = event: { type = "command"; command = "${bridge} hook ${event}"; timeout = 5; };
  toolEvents = [ "PreToolUse" "PostToolUse" ];
  lifecycleEvents = [ "SessionStart" "PreInvocation" "Stop" ];
  hooks = {
    quickshell =
      lib.genAttrs toolEvents (e: [ { matcher = "*"; hooks = [ (handler e) ]; } ])
      // lib.genAttrs lifecycleEvents (e: [ (handler e) ]);
  };
  # Keys this module owns in ~/.gemini/antigravity-cli/settings.json. The file
  # stays writable so agy can still save trusted folders and permissions.
  settings = {
    statusLine = { type = "command"; command = "${bridge} statusline"; };
  };

  hooksJson = pkgs.writeText "agy-hooks.json" (builtins.toJSON hooks);
  settingsJson = pkgs.writeText "agy-managed-settings.json" (builtins.toJSON settings);
in
{
  home.file = {
    ".gemini/GEMINI.md".source = ../../antigravity/GEMINI.md;
    ".gemini/AGENTS.md".source = ../../antigravity/GEMINI.md;
    ".gemini/config/GEMINI.md".source = ../../antigravity/GEMINI.md;
  };

  home.activation.antigravitySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    merge() {
      file="$1"; managed="$2"
      run mkdir -p "$(dirname "$file")"
      [ -s "$file" ] || echo '{}' > "$file"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq -s '.[0] + .[1]' "$file" "$managed" > "$tmp"; then
        run mv "$tmp" "$file"
      else
        rm -f "$tmp"
        echo "antigravity: $file is not valid JSON, left untouched" >&2
      fi
    }
    merge "$HOME/.gemini/config/hooks.json" ${hooksJson}
    merge "$HOME/.gemini/antigravity-cli/settings.json" ${settingsJson}
  '';
}
