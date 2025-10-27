#!/usr/bin/env bash

reload_tmux() {
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        for session in $(tmux list-sessions -F '#S' 2>/dev/null); do
            tmux source-file ~/.tmux.conf 2>/dev/null || true
        done
    fi
}
