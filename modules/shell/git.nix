{ lib, config, options, pkgs, configRoot, ...}:

with lib;
let cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
      enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      git
    ];

    home.configFile = {
      "git" = {
        source = "${configRoot}/config/git";
        recursive = true;
      };
    };
  };
}
