{ lib, config, inputs, pkgs, ...}:

with lib;
mkMerge [
  (mkIf (config.modules.profiles.platform == "wsl") {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];

    wsl.enable = true;
    wsl.defaultUser = config.user.name;
  })
]
