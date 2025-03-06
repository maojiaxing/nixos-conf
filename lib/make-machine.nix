{ inputs, ... }:

{
  hostname,
  system ? "x86_64-linux",
  hardware ? null,
  ...
}@args:

let

  defaultModule = { ... }: {
    networking.hostName = hostname;
    nixpkgs.config.allowUnfree = true;
  };
  
  hardwareModule =
    if (builtins.pathExists (../hosts + "/${hostname}/hardware.nix"))
    then { imports = [ (../hosts + "/${hostname}/hardware.nix") ]; }
    else {};

  homeManagerModule = inputs.home-manager.nixosModules.home-manager {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs hostname; };
    };
  };

  finalModules = [
    defaultModule
    hardwareModule
    homeManagerModule
  ] ++ (args.profiles or []);
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = finalModules;
  specialArgs = {
    inherit inputs hostname;
  };

}
