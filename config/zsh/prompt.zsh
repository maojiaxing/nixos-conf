export VIRTUAL_ENV_DISABLE_PROMPT=1

FUNCNEST=100

if [ -n "$NVIM" ] || [ -n "$VIM" ]; then
    export STARSHIP_FORMAT='$character '
fi

eval "$(starship init zsh)"
