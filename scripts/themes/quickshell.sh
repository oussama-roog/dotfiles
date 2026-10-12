#!/usr/bin/env bash

# Writes the base16 palette as the colour JSON that Quickshell's Theme singleton
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
  "background": "#${colors[base00]}",
  "surface_low": "#${colors[base00]}",
  "surface_high": "#${colors[base01]}",
  "surface_highest": "#${colors[base02]}",
  "border": "#${colors[base02]}",
  "text_bright": "#${colors[base07]}",
  "text": "#${colors[base05]}",
  "text_subtle": "#${colors[base04]}",
  "text_dim": "#$(_qs_mix "${colors[base04]}" "${colors[base03]}" 0.5)",
  "text_faint": "#${colors[base03]}",
  "icon": "#$(_qs_mix "${colors[base05]}" "${colors[base04]}" 0.5)",
  "accent": "#${accent}",
  "accent_container": "#$(_qs_mix "$accent" "${colors[base00]}" 0.55)"
}
EOF
}
