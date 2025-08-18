{ lib, config, options, pkgs, ...}:

with lib;
{
  options.modules.shell.direnv = {
    enable = mkOption {
      inherit default;
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.direnv.enable {
    programs.direnv.enable = true;
  };
}
