{ lib, config, options, pkgs, inputs, ...}:

with lib;
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  options.home = with lib.types; {
    homeDir = mkOpt str "${config.user.home}";
    configDir = mkOpt str "${config.user.home}/.config";
  };

  config = {
    environment = {
      localBinInPath = true;


    };
  };
}
