{ lib, config, options, pkgs, ...}:

with lib;
{
  options.modules.shell.direnv = {
    enable = mkEnableOption "direnv integration";
  };

  config = mkIf config.modules.shell.direnv.enable {
    programs.direnv.enable = true;
    #nix-direnv.enable = true;
  };
}
