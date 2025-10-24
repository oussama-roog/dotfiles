# Sample .bashrc for SUSE Linux
# Copyright (c) SUSE Software Solutions Germany GmbH

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

eval "$(starship init bash)"
test -s ~/.alias && . ~/.alias || true

eval "$(zoxide init bash)"

alias v="nvim"
alias y="yazi"
alias ta='tmux attach-session -t oussama || tmux new-session -s oussama'
alias lg="lazygit"

# # Load Angular CLI autocompletion.
# source <(ng completion script)

alias op='~/.tmux-sessionizer'
export PATH=$HOME/.local/bin:$PATH

alias data="sudo mount -t ntfs-3g /dev/nvme0n1p5 /mnt/data"
alias udata="sudo umount /mnt/data"

# Load fzf key bindings and completion
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
source /usr/share/fzf/shell/key-bindings.bash
