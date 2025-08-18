{ lib, config, inputs, pkgs, ...}:

with lib;
mkMerge [
  (mkIf (config.modules.profiles.platform == "wsl") {

    wsl.enable = true;
    wsl.defaultUser = config.user.name;
  })
]
