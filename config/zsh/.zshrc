# History 
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# Shell Behaviour
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT


# Smart Directory navigation & lf
LF_ICONS=$(cat ~/.config/lf/icons | tr '\n' ':')
export LF_ICONS

# Initialize zoxide
eval "$(zoxide init zsh)"

# Completion
autoload -Uz compinit
compinit -d "$XGD_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Fuzzy finder
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
elif [[ -d /run/current-system/sw/share/fzf ]]; then
  source /run/current-system/sw/share/fzf/key-bindings.zsh
  source /run/current-system/sw/share/fzf/completion.zsh
elif [[ -d "$HOME/.nix-profile/share/fzf" ]]; then
  source "$HOME/.nix-profile/share/fzf/key-bindings.zsh"
  source "$HOME/.nix-profile/share/fzf/completion.zsh"
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  elif [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
    source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# Modular Config Files
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/prompt.zsh"


