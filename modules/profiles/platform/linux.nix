{ lib, config, pkgs, ... }:

with lib;
mkIf (config.modules.profiles.platform == "linux") {

  
}
