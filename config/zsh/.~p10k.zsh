# Powerlevel10k configuration file.
# Style: Custom, single-line prompt with stateful Git colors.
# Generated on: 2025-08-21
#
# To regenerate a new default config, type `p10k configure`.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'       ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'       ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Define only the colors that are actually used in this theme.
  local green='2'
  local yellow='3'
  local blue='4'
  local white='7'

  # =============================================================
  # == PROMPT LAYOUT AND STYLE
  # =============================================================

  # 1. Prompt Elements: Left side has directory and git status. Right side is empty.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( dir vcs )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # 2. Overall Appearance: A clean, single-line prompt with no extra icons or lines.
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=' '

  # 3. Static Prefix: Add 'ε >> ' before all other prompt elements.
  # %b...%b makes the epsilon symbol bold.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_SUBST='%bε%b >> '

  # =============================================================
  # == SEGMENT CONFIGURATION
  # =============================================================

  # 4. Directory Segment (`dir`): Emulates `\W`.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_last'

  # 5. Git Status Segment (`vcs`): Stateful colors for the branch name.
  # When Git repository is clean (no changes).
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$green
  # When Git repository is modified (staged, unstaged, or untracked files).
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$yellow
  # Format the output as `(branch_name)`.
  typeset -g POWERLEVEL9K_VCS_FORMAT='(%b)'
  # Ensure no extra icons are displayed for a minimal look.
  typeset -g POWERLEVEL9K_VCS_SHOW_ON_UPSTREAM='never'
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=

  # 6. Prompt Character Segment (`prompt_char`): The final symbol.
  # Use '↬' as the prompt symbol for all states and modes.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='↬'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION=$'↬'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION=$'↬'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION=$'↬'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION=$'↬'
  # Set the symbol color to white.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_{VIINS,VICMD,VIVIS}_FOREGROUND=$white

  # =============================================================
  # == CORE POWERLEVEL10K SETTINGS
  # =============================================================

  # Instant prompt mode.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  # Disable hot reload for a minor performance improvement.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # Reload Powerlevel10k if it's already running.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
