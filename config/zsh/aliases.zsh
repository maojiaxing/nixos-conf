# Aliases
alias ls='eza'
alias ll='eza -lh'
alias la='eza -lah'
alias tree='eza --icons'
alias cat='bat'
compdef eza=ls

# Utilities
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
#alias vim='nvim'

# Navigation
alias -- -='cd -' 

alias glog='PAGER="less -F -X" git log'
