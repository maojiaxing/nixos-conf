{ lib, options, config, ...}:

with lib;
mkMerge [{
  options.modules.profiles = with types; {
    hardware = mkOpt (listOf str) [];
    platform = mkOpt (enum [ "linux" "darwin" "wsl" ]) "linux";
    role = mkOpt (listOf str) [ "base" ];
    user = mkOpt attrs {};
  };
}]
