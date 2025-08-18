{ lib, config, inputs, pkgs, ...}:

with lib;
mkIf (config.modules.profiles.platform == "wsl")
mkMerge [
  inputs.nixos-wsl.nixosModules.default

  {
    wsl.enable = true;
  }
]
