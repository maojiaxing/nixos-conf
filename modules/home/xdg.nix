{ lib, config, options, ... }:

with lib;
let
  cfg = config.modules.xdg;

in {

  options.modules.xdg = {
    enable = mkBoolOpt true;
    ssh.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nix.settings.use-xdg-base-directories = true;

      environment = {
        systemPackages = [ pkgs.xdg-user-dirs ];

        variables = {
          BASH_COMPLETION_USER_FILE = "$XDG_CONFIG_HOME/bash/completion";
          ENV             = "$XDG_CONFIG_HOME/shell/shrc";  # sh, ksh

          WGETRC          = "$XDG_CONFIG_HOME/wgetrc";
        };

        etc."xdg/user-dirs.conf".text = ''
            enabled=False
          '';

        shellAliases = {
          wget = ''wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'';
        };
      };

      home.configFile."user-dirs.dirs".text = ''
        XDG_DESKTOP_DIR="${home.fakeDir}/Desktop"
        XDG_DOCUMENTS_DIR="${home.fakeDir}/Documents"
        XDG_DOWNLOAD_DIR="${home.fakeDir}/Downloads"
        XDG_PICTURES_DIR="${home.fakeDir}/Pictures"
        XDG_MUSIC_DIR="${home.fakeDir}/Music"
        XDG_VIDEOS_DIR="${home.fakeDir}/Videos"
        XDG_WORKSPACE_DIR="${home.fakeDir}/Workspace"
      '';

      system.userActivationScripts.initXDG = ''
        for dir in "$XDG_DESKTOP_DIR" "$XDG_STATE_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_BIN_HOME" "$XDG_CONFIG_HOME"; do
          mkdir -p "$dir" -m 700
        done

        # Populate the fake home with .local and .config, so certain things are
        # still in scope for the jailed programs, like fonts, data, and files,
        # should they choose to use them at all.
        fakehome="${home.fakeDir}"
        mkdir -p "$fakehome" -m 755
        [ -e "$fakehome/.local" ]  || ln -sf ~/.local  "$fakehome/.local"
        [ -e "$fakehome/.config" ] || ln -sf ~/.config "$fakehome/.config"

        # Avoid the creation of ~/.pki (typically by Firefox), by ensuring NSS
        # finds this directory.
        rm -rf "$HOME/.pki"
        mkdir -p "$XDG_DATA_HOME/pki/nssdb"
      '';

      services.dbus.implementation = "broker";
    }
  ]);
}
