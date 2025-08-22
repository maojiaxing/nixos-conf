#!/bin/bash
set -eo pipefail

BWRAP_BIN="@bwrap_bin@"
BASH_BIN="@bash_bin@"
NODE_BIN_PATH="@node_bin_path@"
CLAUDE_BIN="$out/bin/claude-bin"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude-code"
CLAUDE_CACHE_DIR="$XDG_CACHE_HOME/claude-code"
CLAUDE_DATA_DIR="$XDG_DATA_HOME/claude-code"

$BASH_BIN -c "mkdir -p \"$CLAUDE_CONFIG_DIR\" \"$CLAUDE_CACHE_DIR\" \"$CLAUDE_DATA_DIR\""

for config_file in .claude.json .claude.json.backup; do
  if [ -f "$HOME/$config_file" ]; then
    echo "Moving old config file $HOME/$config_file to $CLAUDE_CONFIG_DIR/home/"
    $BASH_BIN -c "mkdir -p \"$CLAUDE_CONFIG_DIR/home\""
    mv "$HOME/$config_file" "$CLAUDE_CONFIG_DIR/home/"
  fi
  if [ ! -f "$CLAUDE_CONFIG_DIR/home/$config_file" ]; then
    echo '{}' > "$CLAUDE_CONFIG_DIR/home/$config_file"
  fi
done


exec "$BWRAP_BIN" \
  --unshare-all \
  --share-net \
  \
  --tmpfs /tmp \
  --dev /dev \
  --proc /proc \
  --dev-bind /dev/dri /dev/dri \
  \
  --ro-bind /etc /etc \
  --ro-bind /usr/share /usr/share \
  --ro-bind /usr/lib /usr/lib \
  --ro-bind /usr/lib64 /usr/lib64 \
  --ro-bind /usr/bin /usr/bin \
  --ro-bind /usr/sbin /usr/sbin \
  --ro-bind-try /opt /opt \
  \
  --symlink /usr/lib /lib \
  --symlink /usr/lib /lib64 \
  --symlink /usr/bin /bin \
  --symlink /usr/bin /sbin \
  --symlink /run /var/run \
  \
  --tmpfs "$HOME" \
  --dir "$HOME/.config" \
  --bind-try "$HOME/.config" "$HOME/.config" \
  --dir "$HOME/.local" \
  --bind-try "$HOME/.local" "$HOME/.local" \
  --dir "$HOME/.cache" \
  --bind-try "$HOME/.cache" "$HOME/.cache" \
  --dir "$HOME/.npm" \
  --bind-try "$HOME/.npm" "$HOME/.npm" \
  \
  --dir "$HOME/.claude" \
  --bind "$CLAUDE_CONFIG_DIR" "$HOME/.claude" \
  --bind "$CLAUDE_CONFIG_DIR/.claude.json" "$HOME/.claude.json" \
  --bind "$CLAUDE_CONFIG_DIR/.claude.json.backup" "$HOME/.claude.json.backup" \
  \
  --bind "$PWD" "$PWD" \
  --chdir "$PWD" \
  \
  --setenv HOME "$HOME" \
  --setenv PATH "$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  \
  "$CLAUDE_BIN" "$@"
