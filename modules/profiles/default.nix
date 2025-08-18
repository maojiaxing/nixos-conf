{ lib, options, config, ...}:

with lib;
with types;
mkMerge [
  {
    options.modules.profiles = {
      hardware = mkOpt (listOf str) [];
      platform = mkOpt (enum [ "linux" "darwin" "wsl" ]) "linux";
      role = mkOpt (listOf str) [ "base" ];
      user = mkOpt attrs {};
  }
]
