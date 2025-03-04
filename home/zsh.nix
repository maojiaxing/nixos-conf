{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  programs.zsh.initExtra = ''
    if [ -z "$SSH_AUTH_SOCK" ]; then
      eval "$(ssh-agent -s)" >/dev/null
      ssh-add ~/.ssh/github 2>/dev/null
    fi
  ''
}
