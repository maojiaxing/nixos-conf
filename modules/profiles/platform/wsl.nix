{ lib, config, inputs, pkgs, ...}:

with lib;
mkIf (config.modules.profiles.platform == "wsl") (
  mkMerge [
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default;
      ];
    }

    {
      wsl.enable = true;
      wsl.defaultUser = config.user.name;
    }
  ]
)
