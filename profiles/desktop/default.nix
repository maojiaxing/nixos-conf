{ lib, config, options }:

with lib;
let 
  cfg = config.profile.desktop = {
    enable = mkDefault true;
  }