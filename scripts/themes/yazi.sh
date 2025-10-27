#!/usr/bin/env bash

apply_yazi_theme() {
    cat > "$CONFIG_DIR/yazi/theme.toml" << EOF
[mgr]
cwd = { fg = "#${colors[base05]}" }
hovered = { bg = "#${colors[base02]}" }
find_keyword = { fg = "#${colors[base0A]}", bold = true }
marker_copied = { bg = "#${colors[base0B]}" }
marker_cut = { bg = "#${colors[base0A]}" }
tab_active = { fg = "#${colors[base05]}", bold = true }
tab_inactive = { fg = "#${colors[base04]}" }
border_style = { fg = "#${colors[base03]}" }

[mode]
normal_main = { fg = "#${colors[base05]}", bg = "#${colors[base00]}" }
select_main = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }

[status]
overall = { fg = "#${colors[base05]}", bg = "#${colors[base00]}" }
perm_type = { fg = "#${colors[base0D]}" }
perm_read = { fg = "#${colors[base0B]}" }
perm_write = { fg = "#${colors[base0A]}" }
perm_exec = { fg = "#${colors[base08]}" }
progress_normal = { fg = "#${colors[base05]}", bg = "#${colors[base01]}" }
progress_error = { fg = "#${colors[base08]}" }

[pick]
border = { fg = "#${colors[base03]}" }
active = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }
inactive = { fg = "#${colors[base05]}" }

[input]
border = { fg = "#${colors[base03]}" }
value = { fg = "#${colors[base05]}" }
selected = { bg = "#${colors[base02]}" }

[cmp]
border = { fg = "#${colors[base03]}" }
active = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }
inactive = { fg = "#${colors[base05]}" }

[tasks]
border = { fg = "#${colors[base03]}" }
hovered = { bg = "#${colors[base02]}" }

[help]
on = { fg = "#${colors[base0D]}" }
desc = { fg = "#${colors[base05]}" }
hovered = { bg = "#${colors[base02]}" }

[notify]
title_info = { fg = "#${colors[base0D]}" }
title_warn = { fg = "#${colors[base0A]}" }
title_error = { fg = "#${colors[base08]}" }

[filetype]
rules = [
        { name = "*/", fg = "#${colors[base0D]}" },
        { name = "*", fg = "#${colors[base05]}" }
]

EOF
}
