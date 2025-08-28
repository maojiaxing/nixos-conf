{ lib, ...}:

{
  imports = [
    ./storage.nix
  ];

  modules = {
    hardware = { cpu = "intel";}; 

    profile = {
      roles = [ "router" "hypervisor" ];
    };


  };
}
