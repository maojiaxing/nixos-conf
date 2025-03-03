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

  finalModules = [
    hardwareModule
    ({ ... }: { networking.hostName = hostname; })
  ] ++ (args.profiles or []);
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = finalModules;
  specialArgs = {
    inherit inputs hostname;
  };

}
