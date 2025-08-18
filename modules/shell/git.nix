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
  };
}
