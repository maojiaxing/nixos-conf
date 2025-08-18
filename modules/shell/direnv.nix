{ lib, config, options, pkgs, ...}:

with lib;
{
  options.modules.shell.direnv = {
    enable = mkOption {
      description = "Whether to enable direnv to load and unload environment variables depending on the current directory.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.shell.direnv.enable {
    programs.direnv.enable = true;
  };
}
