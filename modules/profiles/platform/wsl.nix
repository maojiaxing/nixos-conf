{ lib, config, inputs, pkgs, ...}:

with lib;
{
  imports = [
      inputs.nixos-wsl.nixosModules.default
  ];

  config = mkIf(config.modules.profiles.platform == "wsl") {


    wsl.enable = true;
    wsl.defaultUser = config.user.name;
  };
}

