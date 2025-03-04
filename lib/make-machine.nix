{ inputs, ... }:

{
  hostname,
  system ? "x86_64-linux",
  hardware ? null,
  ...
}@args:

let
  
  hardwareModule =
    if (builtins.pathExists (../hosts + "/${hostname}/hardware.nix"))
    then { imports = [ (../hosts + "/${hostname}/hardware.nix") ]; }
    else {};

  bootModule = {
    imports = [ ../hosts/boot.nix ];
  };

  finalModules = [
    hardwareModule
    bootModule
    ({ ... }: { networking.hostName = hostname; nixpkgs.config.allowUnfree = true;})
  ] ++ (args.profiles or []);
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = finalModules;
  specialArgs = {
    inherit inputs hostname;
  };

}
