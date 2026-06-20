# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI
local mocha_bg="#1e1e2e"
local mocha_fg="#cdd6f4"
local mocha_hl="#f38ba8"
local mocha_fg_plus="#cdd6f4"
local mocha_bg_plus="#313244"
local mocha_hl_plus="#f38ba8"
local mocha_info="#cba6f7"
local mocha_marker="#f5e0dc"
local mocha_pointer="#f5e0dc"
local mocha_prompt="#cba6f7"
local mocha_spinner="#f5e0dc"
local mocha_header="#f38ba8"

export FZF_DEFAULT_OPTS='
  --height=~60%
  --layout=reverse
  --border=rounded
  --prompt=" "
  --pointer=""
  --preview-window=right:65%:wrap:border-left
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=border:#89b4fa
  --color=border:-1,info:-1,prompt:-1
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"

  local has_starship=0
  if (( ${+precmd_functions} )); then
    if [[ " ${precmd_functions[@]} " =~ " _starship_precmd " ]]; then
      precmd_functions=(${precmd_functions#_starship_precmd})
      has_starship=1
    fi
  fi

  printf "\r\033[K\r\033[K"

  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  
  if (( has_starship )); then
    precmd_functions+=(_starship_precmd)
  fi

  zle reset-prompt
}
zle -N _fzf_file_no_hidden
