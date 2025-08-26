{ lib, config, pkg, ... }:

with lib;
let 
  hardware = config.modules.profiles.hardware;
in mkMerge [
  (mkIf (any (s: hasPrefix "cpu/amd" s) hardware) {
    hardware.cpu.amd.updateMicrocode =mkDefault config.hardware.enableRedistributableFirmware;
    boot.kernelParams = [ "amd_pstate=active" ];
  })
]
