{ lib, config, options, pkgs, ...}:

with lib;
let cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
      enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      git
    ];

    home.configFile = {
      "git/config".source     = "${configRoot}/git/config";
      "git/ignore".source     = "${configRoot}/git/ignore";
      "git/attributes".source = "${configRoot}/git/attributes";
    };
  };
}
