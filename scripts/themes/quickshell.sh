#!/usr/bin/env bash

# Writes the base16 palette as the colour JSON that Quickshell's Dyn singleton
# watches, so the shell recolours live without a restart.

QUICKSHELL_COLORS="$CONFIG_DIR/quickshell/colors.json"

# Blend two hex colours (no '#'): mix a b t -> a*(1-t) + b*t
_qs_mix() {
    awk -v a="$1" -v b="$2" -v t="$3" 'BEGIN {
        for (i = 0; i < 3; i++) {
            x = strtonum("0x" substr(a, i*2+1, 2)); y = strtonum("0x" substr(b, i*2+1, 2))
            printf "%02x", int(x + (y - x) * t + 0.5)
        }
    }'
}

# Most saturated of the accent slots, so grey-heavy schemes still get a real accent
_qs_accent() {
    local best="" best_s=-1 key hex
    for key in base08 base09 base0A base0B base0C base0D base0E; do
        hex="${colors[$key]}"
        s=$(awk -v h="$hex" 'BEGIN {
            r = strtonum("0x" substr(h,1,2)); g = strtonum("0x" substr(h,3,2)); b = strtonum("0x" substr(h,5,2))
            mx = r; if (g > mx) mx = g; if (b > mx) mx = b
            mn = r; if (g < mn) mn = g; if (b < mn) mn = b
            printf "%d", (mx == 0) ? 0 : (mx - mn) * 1000 / mx
        }')
        if (( s > best_s )); then best_s=$s; best=$hex; fi
    done
    echo "$best"
}

apply_quickshell_theme() {
    local accent
    accent=$(_qs_accent)

    mkdir -p "$(dirname "$QUICKSHELL_COLORS")"
    # Written in place (not tmp+mv) so the FileView watch keeps its inode
    cat >"$QUICKSHELL_COLORS" <<EOF
{
  "surface": "#${colors[base00]}",
  "surface_container_low": "#${colors[base00]}",
  "surface_container": "#${colors[base01]}",
  "surface_container_high": "#${colors[base01]}",
  "surface_container_highest": "#${colors[base02]}",
  "primary": "#${accent}",
  "primary_container": "#$(_qs_mix "$accent" "${colors[base00]}" 0.55)",
  "on_primary_container": "#$(_qs_mix "$accent" "${colors[base07]}" 0.45)",
  "outline": "#${colors[base03]}",
  "outline_variant": "#${colors[base02]}",
  "cream": "#${colors[base05]}",
  "bright": "#${colors[base07]}",
  "subtle": "#${colors[base04]}",
  "dim": "#$(_qs_mix "${colors[base04]}" "${colors[base03]}" 0.5)",
  "faint": "#${colors[base03]}",
  "icon_dim": "#$(_qs_mix "${colors[base05]}" "${colors[base04]}" 0.5)",
  "tick_rest": "#${colors[base04]}"
}
EOF
}
