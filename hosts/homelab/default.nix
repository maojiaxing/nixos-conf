{ lib, ...}:

{
  imports = [
    ./storage.nix
  ];

  modules = {
    profile = {
      hardware = { cpu = "intel";}; 
      roles = [ "router" "hypervisor" ];
    };


  };
}
