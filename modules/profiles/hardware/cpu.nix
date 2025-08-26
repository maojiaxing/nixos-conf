{ lib, config, pkg, ... }:

with lib;
let 
  cpu = config.modules.profiles.hardware.cpu;
in {
  options.modules.profiles.hardwrae = {
    cpu = mkOpt' (types.enum [ "intel" "amd" "arm" "none" ]) "none" "The vendor/architecture of the CPU for this host.";
  };

  (lib.mkIf (cpu == "intel") {
    hardware.cpu.intel.updateMicrocode = true;
  });

  (lib.mkIf (cpu == "amd") {
    hardware.cpu.amd.updateMicrocode = true;
  });
}
