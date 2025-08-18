{ lib, config, inputs, pkgs, ...}:

with lib;
mkIf (config.modules.profiles.platform == "wsl") {


  config = {
    

    wsl.enable = true;
    wsl.defaultUser = config.user.name;
  };
}
