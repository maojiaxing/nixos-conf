{ lib, config, options, pkgs, inputs, ...}:

with lib;
{
  imports = [
    inputs.home-manager.default
  ];

  options.home = with lib.types; {
    homeDir = mkOpt str "${config.user.home}";
    configDir = mkOpt str "";
  };

  config = {
    environment = {
      localBinInPath = true;


    };
  };
}
