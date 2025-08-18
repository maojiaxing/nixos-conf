{ lib, config, options, pkgs, ...}:

with lib;
{
  options.modules.shell.direnv = {
    enable = mkBootOpt false;
  };

  config = mkIf config.modules.shell.direnv.enable {
    programs.direnv.enable = true;
  };
}
