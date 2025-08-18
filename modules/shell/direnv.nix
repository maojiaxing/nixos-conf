{ lib, config, options, pkgs, ...}:

with lib;
{
  options.modules.shell.direnv = {
    enable = mkBootOpt false;
  };

  config = mkIf config.modules.shell.direnv {
    programs.direnv.enable = true;
  };
}
