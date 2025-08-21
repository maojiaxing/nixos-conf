

function xcache() {
  case $1 in
    [/~]*) [[ -x "$1" ]] || return 1 ;;
    *) (( $+commands[$1] )) || return 1 ;;
  esac
  local cache="$XDG_CACHE_HOME/zsh/${1:t}-${ZSH_VERSION}"
  if [[ ! -f $cache || ! -s $cache ]]; then
      echo "Caching ${1:t:r}..."
      mkdir -p "${cache:h}"
      "$@" >"$cache"
      chmod 600 "$cache"
  fi
  if [[ -o interactive ]]; then
      source "$cache" || rm -f "$cache"
  fi
}
