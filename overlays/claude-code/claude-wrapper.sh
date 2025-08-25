#!/bin/bash
set -eo pipefail

BWRAP_BIN="@bwrap_bin@"
BASH_BIN="@bash_bin@"
CLAUDE_BIN="$out/bin/claude"
NODE_BIN_PATH="@node_bin_path@"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude-code"
CLAUDE_CACHE_DIR="$XDG_CACHE_HOME/claude-code"
CLAUDE_DATA_DIR="$XDG_DATA_HOME/claude-code"

$BASH_BIN -c "mkdir -p \"$CLAUDE_CONFIG_DIR\" \"$CLAUDE_CACHE_DIR\" \"$CLAUDE_DATA_DIR\""

for config_file in .claude.json .claude.json.backup; do
  if [ -f "$HOME/$config_file" ]; then
    echo "Moving old config file $HOME/$config_file to $CLAUDE_CONFIG_DIR/"
    mv "$HOME/$config_file" "$CLAUDE_CONFIG_DIR/"
  fi
done

BWRAP_ENV_ARGS=()
CLAUDE_SETTINGS_FILE="$CLAUDE_CONFIG_DIR/settings.json"
if [ -f "$CLAUDE_SETTINGS_FILE" ]; then
  # 使用 jq 读取 .env 对象中的所有键值对，并为 bwrap 构建 --setenv 参数
  while IFS= read -r -d '' key && IFS= read -r -d '' value; do
    if [ -n "$key" ]; then
      BWRAP_ENV_ARGS+=(--setenv "$key" "$value")
    fi
  done < <(jq -j '.env | to_entries[] | .key, "\u0000", .value, "\u0000"' "$CLAUDE_SETTINGS_FILE")
fi

exec "$BWRAP_BIN" \
  --unshare-all \
  --share-net \
  \
  --tmpfs /tmp \
  --dev /dev \
  --proc /proc \
  --dev-bind /dev/dri /dev/dri \
  \
  --ro-bind /nix/store /nix/store \
  --ro-bind /etc /etc \
  --ro-bind /usr/lib /usr/lib \
  --ro-bind /usr/bin /usr/bin \
  --ro-bind-try /usr/share /usr/share \
  --ro-bind-try /usr/sbin /usr/sbin \
  --ro-bind-try /usr/lib64 /usr/lib64 \
  \
  --symlink /usr/lib /lib \
  --symlink /usr/lib /lib64 \
  --symlink /usr/bin /bin \
  --symlink /usr/bin /sbin  \
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
  --bind-try "$CLAUDE_CONFIG_DIR/.claude" "$HOME/.claude" \
  --bind-try "$CLAUDE_CONFIG_DIR/.claude.json" "$HOME/.claude.json" \
  --bind-try "$CLAUDE_CONFIG_DIR/.claude.json.backup" "$HOME/.claude.json.backup" \
  \
  --bind "$PWD" "$PWD" \
  --chdir "$PWD" \
  \
  --setenv HOME "$HOME" \
  --setenv PATH "$NODE_BIN_PATH:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  \
  "${BWRAP_ENV_ARGS[@]}" \
  \
  "$CLAUDE_BIN" "$@"
