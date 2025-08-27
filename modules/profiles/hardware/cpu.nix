{ lib, config, pkg, ... }:

with lib;
let 
  cpu = config.modules.profiles.hardware.cpu;
in {
  options.modules.profiles.hardwrae = {
    cpu = mkOpt' (types.enum [ "intel" "amd" "arm" "none" ]) "none" "The vendor/architecture of the CPU for this host.";
  };

  config = mkMerge [
    (mkIf (cpu == "intel") {
      hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    })

    (mkIf (cpu == "amd") {
      hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
      boot.kernelParams = [ "amd_pstate=active" ];
    })
  ];
}
