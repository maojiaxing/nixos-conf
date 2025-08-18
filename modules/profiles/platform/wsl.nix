{ lib, config, inputs, pkgs, ...}:

with lib;
mkIf (config.modules.profiles.platform == "wsl") {
  imports = [
      inputs.nixos-wsl.nixosModules.default
  ];

  config = {
    wsl.enable = true;
    wsl.defaultUser = config.user.name;
  };
}
