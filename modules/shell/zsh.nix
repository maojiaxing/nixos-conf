{ lib, config, options, pkgs, ...}:

with lib;
let
  cfg = config.modules.shell.zsh;
in {

  options.modules.shell.zsh = with types; {
    enable = mkBoolOpt true;

    rcInit = mkOpt' lines "" ''
      Zsh lines to be written to $XDG_CONFIG_HOME/zsh/extra.zshrc and sourced by
      $XDG_CONFIG_HOME/zsh/.zshrc
    '';

    envInit = mkOpt' lines "" ''
      Zsh lines to be written to ${config.home.configDir}/zsh/extra.zshenv and
      sourced by $XDG_CONFIG_HOME/zsh/.zshenv
    '';

    rcFiles  = mkOpt (listOf (either str path)) [];
    envFiles = mkOpt (listOf (either str path)) [];
  };

  config = mkIf cfg.enable {
     programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      histFile = "$XDG_STATE_HOME/zsh/history";
      enableLsColors = false;
    };

    user.packages = with pkgs; [
      bat      # a better cat
      bc
      dust     # a better du
      eza      # a better ls
      fasd
      fd
      fzf
      gnumake
    ];

    environment.variables = {
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
      ZGEN_DIR = "$XDG_DATA_HOME/zgenom";
      _FASD_DATA = "$XDG_CACHE_HOME/fasd";
      _FASD_VIMINFO = "$XDG_CACHE_HOME/viminfo";
    };

    systemd.user.tmpfiles.rules = [
      "d %h/.cache/zsh 750 - - - -"
      "d %h/.local/state/zsh 700 - - - -"
    ];

    # home.configFile = {
    #   "zsh" = {
    #     source = "${config.home.homeDir}/.config/zsh"; recursive = true;
    #   };

    # };
  };
}
