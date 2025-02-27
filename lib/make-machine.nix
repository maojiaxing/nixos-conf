{ lib, inputs, ... }:
args@{ 
  hostname,
  system ? "x86_64-linux",
  hardware ? null,
  ...
}:

let
  # 自动检测硬件配置是否存在
  hardwareModule = 
    if (builtins.pathExists (../hosts + "/${hostname}/hardware.nix"))
    then { imports = [ (../hosts + "/${hostname}/hardware.nix") ]; }
    else {};

  # 合并所有模块
  finalModules = [
    hardwareModule
    ({ ... }: { networking.hostName = hostname; })
  ] ++ (args.modules or []);
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = finalModules;
  specialArgs = {
    inherit inputs hostname;
  };
  
}
