# theme-switch — runtime theme switcher
# Reads contract files written by modules.themes:
#   /run/current-system/themes-catalog.json
#   /run/current-system/theme-name

readonly CATALOG=/run/current-system/themes-catalog.json
readonly CURRENT=/run/current-system/theme-name
readonly HM_SPEC_DIR="${HOME}/.local/state/nix/profiles/home-manager/specialisation"
readonly SUDO=/run/wrappers/bin/sudo

die()  { printf 'theme-switch: %s\n' "$*" >&2; exit 1; }
warn() { printf 'theme-switch: %s\n' "$*" >&2; }

require_catalog() {
  [[ -f $CATALOG ]] || die "catalog not found: $CATALOG (modules.themes enabled?)"
  local ver
  ver=$(jq -r '.schemaVersion // empty' "$CATALOG")
  [[ $ver == "1" ]] || die "unsupported catalog schemaVersion: ${ver:-<missing>}"
}

list_themes() {
  require_catalog
  jq -r '.themes | keys[]' "$CATALOG"
}

current_theme() {
  [[ -f $CURRENT ]] || die "no current-theme marker at $CURRENT"
  cat "$CURRENT"
}

info_theme() {
  require_catalog
  if [[ $# -eq 0 ]]; then
    jq '.themes' "$CATALOG"
  else
    jq -e --arg t "$1" '.themes[$t]' "$CATALOG" \
      || die "unknown theme: $1"
  fi
}

menu_pick() {
  require_catalog
  local menu="${THEME_SWITCH_MENU:-fzf}"
  local items
  items=$(
    jq -r '.themes
           | to_entries
           | .[]
           | "\(.key)\t\(.value.polarity)\t\(.value.description // "")"' \
        "$CATALOG"
  )

  case "$menu" in
    fzf)
      printf '%s\n' "$items" \
        | fzf --with-nth=1,2,3 --delimiter=$'\t' --prompt='theme> ' \
        | cut -f1
      ;;
    rofi)
      command -v rofi >/dev/null 2>&1 || die "rofi not installed"
      printf '%s\n' "$items" \
        | rofi -dmenu -i -p 'theme' \
        | cut -f1
      ;;
    tofi)
      command -v tofi >/dev/null 2>&1 || die "tofi not installed"
      printf '%s\n' "$items" \
        | tofi --prompt-text='theme: ' \
        | cut -f1
      ;;
    none)
      die "menu disabled (THEME_SWITCH_MENU=none); supply <name> explicitly"
      ;;
    *)
      die "unsupported menu backend: $menu"
      ;;
  esac
}

push_wallpaper() {
  [[ ${THEME_SWITCH_NO_WALL:-0} == 1 ]] && return 0
  local wall="$1"
  [[ -e $wall ]] || { warn "wallpaper missing: $wall"; return 0; }

  if command -v swww >/dev/null 2>&1; then
    swww img "$wall" --transition-type fade >/dev/null 2>&1 || true
  elif command -v hyprctl >/dev/null 2>&1; then
    hyprctl hyprpaper wallpaper ",$wall" >/dev/null 2>&1 || true
  elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg >/dev/null 2>&1 || true
    swaybg -i "$wall" -m fill >/dev/null 2>&1 &
    disown
  elif command -v feh >/dev/null 2>&1; then
    feh --bg-fill "$wall" >/dev/null 2>&1 || true
  else
    warn "no known wallpaper setter; will refresh on next rebuild"
  fi
}

activate_nixos() {
  local target="$1" persist="$2"
  local active
  active=$(jq -r .active "$CATALOG")

  local root=/run/current-system
  if [[ $target != "$active" ]]; then
    root=/run/current-system/specialisation/$target
  fi

  [[ -x "$root/bin/switch-to-configuration" ]] \
    || die "specialisation not found: $root (have you rebuilt since adding it?)"

  local action=test
  [[ $persist == 1 ]] && action=switch

  "$SUDO" "$root/bin/switch-to-configuration" "$action"
}

activate_hm() {
  local target="$1"
  local script="$HM_SPEC_DIR/$target/activate"
  [[ -x $script ]] || return 0
  "$script"
}

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a theme-switch "Theme" "Switched to $1" || true
}

switch_theme() {
  require_catalog
  local target="$1" persist="$2"

  jq -e --arg t "$target" '.themes[$t]' "$CATALOG" >/dev/null \
    || die "unknown theme: $target (use --list)"

  activate_nixos "$target" "$persist"
  activate_hm "$target"

  local wall
  wall=$(
    jq -r --arg t "$target" '.themes[$t].wallpaper' \
      /run/current-system/themes-catalog.json
  )
  push_wallpaper "$wall"

  notify "$target"
}

usage() {
  cat <<EOF
theme-switch — runtime theme switcher

Usage:
  theme-switch                    Interactive menu (\$THEME_SWITCH_MENU, default: fzf)
  theme-switch <name>             Switch to named theme (test, current session only)
  theme-switch --persist <name>   Switch and persist (writes bootloader entry)
  theme-switch --list             List available themes
  theme-switch --current          Print currently active theme
  theme-switch --info [<name>]    Print theme metadata (all themes if <name> omitted)
  theme-switch --help             Show this help

Environment:
  THEME_SWITCH_MENU=fzf|rofi|tofi|none   Menu backend (default: fzf)
  THEME_SWITCH_PERSIST=1                 Equivalent to --persist
  THEME_SWITCH_NO_WALL=1                 Skip wallpaper push
EOF
}

main() {
  local persist=${THEME_SWITCH_PERSIST:-0}

  case "${1:-}" in
    -h|--help)  usage ;;
    --list)     list_themes ;;
    --current)  current_theme ;;
    --info)     shift; info_theme "$@" ;;
    --persist)
      shift
      [[ $# -ge 1 ]] || die "--persist requires <name>"
      switch_theme "$1" 1
      ;;
    "")         switch_theme "$(menu_pick)" "$persist" ;;
    --*)        die "unknown flag: $1 (try --help)" ;;
    *)          switch_theme "$1" "$persist" ;;
  esac
}

main "$@"
