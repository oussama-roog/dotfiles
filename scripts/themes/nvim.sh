#!/usr/bin/env bash

apply_nvim_theme() {
    local theme_name=$1
    
    cat > "$CONFIG_DIR/nvim/lua/oussama/core/theme.lua" << EOF
vim.cmd.colorscheme("base16-$theme_name")
EOF
}

reload_nvim() {
    local theme_name=$1
    if command -v nvim >/dev/null 2>&1; then
        for socket in /tmp/nvim*.sock; do
            [[ -S "$socket" ]] && nvim --server "$socket" --remote-expr "execute('colorscheme base16-$theme_name')" 2>/dev/null || true
        done
    fi
}
