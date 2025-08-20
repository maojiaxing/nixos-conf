{ lib, config, options, pkgs, ...}:

with lib;
let
  cfg = config.modules.services.syncthing;
in {
  options.modules.services.syncthing {
    enable = mkBoolOpt false;
  };

  config = if cfg.enable {
    services.syncthing = rec {
      enable = true;
      openDefaultPorts = true;
      user = config.user.name;
      configDir = "${config.home.configDir}/syncthing";
      dataDir = "${config.home.dataDir}/syncthing";
    }
  }
}
