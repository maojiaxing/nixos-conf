{ lib, config, options, pkgs, inputs, ...}:

with lib;
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  options.home = with lib.types; {
    homeDir = mkOpt str "/home/${config.user.home}";
    configDir = mkOpt str "/home/${config.user.home}/.config";
  };

  config = {
    environment = {
      localBinInPath = true;


    };
  };
}
